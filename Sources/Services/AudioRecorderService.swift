import Foundation
import AVFoundation

/// Records audio from the microphone to a temporary .wav file using AVAudioEngine.
@MainActor
final class AudioRecorderService {

    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var outputURL: URL?
    private var metrics = AudioRecordingMetrics()
    private var inputSampleRate: Double = 0

    private(set) var lastErrorMessage: String?

    /// The exact Date when recording started (used for clipboard timestamp alignment)
    private(set) var recordingStartTime: Date = .distantPast

    /// Starts recording from the default input device.
    /// Throws if the microphone is unavailable or the engine fails to start.
    func startRecording() throws {
        lastErrorMessage = nil
        metrics.reset()
        outputURL = nil
        audioFile = nil
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        inputSampleRate = inputFormat.sampleRate
        let inputDeviceName = AudioInputDeviceService.defaultInputDevice()?.name ?? "Unknown Input"

        guard inputFormat.channelCount > 0, inputFormat.sampleRate > 0 else {
            throw AudioRecorderError.inputUnavailable
        }

        // Create output file in a temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "dikte_\(UUID().uuidString).wav"
        let fileURL = tempDir.appendingPathComponent(fileName)
        let fileSettings = Self.wavFileSettings(
            sampleRate: inputFormat.sampleRate,
            channelCount: inputFormat.channelCount
        )
        var tapInstalled = false

        do {
            let audioFile = try AVAudioFile(
                forWriting: fileURL,
                settings: fileSettings,
                commonFormat: .pcmFormatFloat32,
                interleaved: false
            )
            let recordingMetrics = metrics

            inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { buffer, _ in
                do {
                    try audioFile.write(from: buffer)
                    recordingMetrics.add(buffer: buffer)
                } catch {
                    DikteLog.error("audio", "file.write.failed", error.localizedDescription)
                }
            }
            tapInstalled = true

            engine.prepare()
            try engine.start()

            self.audioEngine = engine
            self.audioFile = audioFile
            self.outputURL = fileURL
            self.recordingStartTime = Date()

            DikteLog.action("audio", "recording.start", "\(Int(inputFormat.sampleRate)) Hz, \(inputFormat.channelCount) kanal, \(inputDeviceName)")
        } catch {
            if tapInstalled {
                inputNode.removeTap(onBus: 0)
            }
            engine.stop()
            audioEngine = nil
            audioFile = nil
            outputURL = nil
            lastErrorMessage = error.localizedDescription
            throw error
        }
    }

    /// Stops recording and returns the URL of the recorded audio file.
    func stopRecording() -> URL? {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil

        let fileURL = outputURL
        let snapshot = metrics.snapshot
        let frameCount = snapshot.frameCount
        audioFile = nil

        guard let fileURL else {
            lastErrorMessage = "Ses kaydı dosyası oluşturulamadı."
            DikteLog.error("audio", "recording.stop", "Dosya yok.")
            return nil
        }

        let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        let byteCount = (attributes?[.size] as? Int64) ?? 0
        let duration = inputSampleRate > 0 ? Double(frameCount) / inputSampleRate : 0

        DikteLog.action(
            "audio",
            "recording.stop",
            "\(String(format: "%.2f", duration))s, \(byteCount) bytes, \(frameCount) frame, rms \(String(format: "%.4f", snapshot.rms)), peak \(String(format: "%.4f", snapshot.peak))"
        )

        guard frameCount > 0, byteCount > 4_096 else {
            lastErrorMessage = "Mikrofondan ses verisi alınamadı. Sistem giriş cihazını kontrol edin."
            DikteLog.error("audio", "recording.empty", "Varsayılan mikrofon veya Bluetooth giriş cihazı çalışmıyor olabilir.")
            return nil
        }

        guard snapshot.sampleCount == 0 || duration < 1.0 || snapshot.peak >= 0.003 else {
            lastErrorMessage = "Mikrofon sinyali çok düşük. Giriş cihazını veya mikrofon iznini kontrol edin."
            DikteLog.warning("audio", "recording.lowSignal", "Ses kaydı var ama sinyal seviyesi çok düşük.")
            return nil
        }

        return fileURL
    }

    private static func wavFileSettings(
        sampleRate: Double,
        channelCount: AVAudioChannelCount
    ) -> [String: Any] {
        [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: Int(channelCount),
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false,
        ]
    }
}

private enum AudioRecorderError: LocalizedError {
    case inputUnavailable

    var errorDescription: String? {
        switch self {
        case .inputUnavailable:
            return "Mikrofon giriş formatı okunamadı. Sistem giriş cihazını kontrol edin."
        }
    }
}

private final class AudioRecordingMetrics: @unchecked Sendable {
    private let lock = NSLock()
    private var frames: AVAudioFramePosition = 0
    private var sampleCount: Int = 0
    private var sumSquares: Double = 0
    private var peak: Float = 0

    var snapshot: AudioRecordingSnapshot {
        lock.lock()
        defer { lock.unlock() }
        let rms = sampleCount > 0 ? sqrt(sumSquares / Double(sampleCount)) : 0
        return AudioRecordingSnapshot(
            frameCount: frames,
            sampleCount: sampleCount,
            rms: rms,
            peak: peak
        )
    }

    func add(buffer: AVAudioPCMBuffer) {
        let frameLength = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        var localSampleCount = 0
        var localSumSquares: Double = 0
        var localPeak: Float = 0

        if let channelData = buffer.floatChannelData {
            for channel in 0..<channelCount {
                let samples = channelData[channel]
                for frame in 0..<frameLength {
                    let value = samples[frame]
                    let magnitude = abs(value)
                    localPeak = max(localPeak, magnitude)
                    localSumSquares += Double(value * value)
                    localSampleCount += 1
                }
            }
        }

        lock.lock()
        frames += AVAudioFramePosition(buffer.frameLength)
        sampleCount += localSampleCount
        sumSquares += localSumSquares
        peak = max(peak, localPeak)
        lock.unlock()
    }

    func reset() {
        lock.lock()
        frames = 0
        sampleCount = 0
        sumSquares = 0
        peak = 0
        lock.unlock()
    }
}

private struct AudioRecordingSnapshot {
    let frameCount: AVAudioFramePosition
    let sampleCount: Int
    let rms: Double
    let peak: Float
}
