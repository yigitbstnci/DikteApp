import Foundation
import AVFoundation

/// Records audio from the microphone to a temporary .wav file using AVAudioEngine.
@MainActor
final class AudioRecorderService {

    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var outputURL: URL?

    /// The exact Date when recording started (used for clipboard timestamp alignment)
    private(set) var recordingStartTime: Date = .distantPast

    /// Starts recording from the default input device.
    /// Throws if the microphone is unavailable or the engine fails to start.
    func startRecording() throws {
        let engine = AVAudioEngine()

        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        // Create output file in a temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "dikte_\(UUID().uuidString).wav"
        let fileURL = tempDir.appendingPathComponent(fileName)

        let audioFile = try AVAudioFile(
            forWriting: fileURL,
            settings: inputFormat.settings,
            commonFormat: inputFormat.commonFormat,
            interleaved: inputFormat.isInterleaved
        )

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { buffer, _ in
            do {
                try audioFile.write(from: buffer)
            } catch {
                print("[Dikte] Ses yazma hatası: \(error.localizedDescription)")
            }
        }

        engine.prepare()
        try engine.start()

        self.audioEngine = engine
        self.audioFile = audioFile
        self.outputURL = fileURL
        self.recordingStartTime = Date()

        print("[Dikte] Kayıt başladı")
    }

    /// Stops recording and returns the URL of the recorded audio file.
    func stopRecording() -> URL? {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        audioFile = nil

        print("[Dikte] Kayıt durduruldu")
        return outputURL
    }
}
