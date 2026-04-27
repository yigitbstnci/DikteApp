import Foundation
import CoreAudio

/// Temporarily silences the default output device while Dikte records.
@MainActor
final class OutputSilenceService {
    private var restoreState: RestoreState?

    func silenceForRecording() {
        guard restoreState == nil else { return }

        guard let deviceID = defaultOutputDeviceID() else {
            DikteLog.warning("output", "silence.missingDevice", "Varsayılan çıkış cihazı bulunamadı.")
            return
        }

        if let previousMute = readMute(deviceID: deviceID), setMute(1, deviceID: deviceID) {
            restoreState = RestoreState(
                deviceID: deviceID,
                previousMute: previousMute,
                previousVolumes: []
            )
            DikteLog.action("output", "silence.mute", "Sistem çıkışı kayıt boyunca susturuldu.")
            return
        }

        let mutedVolumes = muteVolumeChannels(deviceID: deviceID)
        if !mutedVolumes.isEmpty {
            restoreState = RestoreState(
                deviceID: deviceID,
                previousMute: nil,
                previousVolumes: mutedVolumes
            )
            DikteLog.action("output", "silence.volume", "Sistem çıkış seviyesi kayıt boyunca 0'a çekildi.")
            return
        }

        DikteLog.warning("output", "silence.unsupported", "Çıkış cihazı mute/volume kontrolü sağlamıyor.")
    }

    func restore() {
        guard let restoreState else { return }

        var restored = false
        if let previousMute = restoreState.previousMute {
            restored = setMute(previousMute, deviceID: restoreState.deviceID) || restored
        }

        for volume in restoreState.previousVolumes {
            restored = setVolume(volume.value, deviceID: restoreState.deviceID, element: volume.element) || restored
        }

        if restored {
            DikteLog.action("output", "restore.success", "Sistem çıkışı eski haline alındı.")
        } else {
            DikteLog.warning("output", "restore.failed", "Sistem çıkışı eski haline alınamadı.")
        }

        self.restoreState = nil
    }

    private func defaultOutputDeviceID() -> AudioDeviceID? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &deviceID
        )

        guard status == noErr, deviceID != AudioDeviceID(kAudioObjectUnknown) else {
            return nil
        }

        return deviceID
    }

    private func readMute(deviceID: AudioDeviceID) -> UInt32? {
        var address = muteAddress
        guard isSettable(deviceID: deviceID, address: &address) else { return nil }

        var mute = UInt32(0)
        var size = UInt32(MemoryLayout<UInt32>.size)
        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &mute)
        guard status == noErr else { return nil }
        return mute
    }

    private func setMute(_ value: UInt32, deviceID: AudioDeviceID) -> Bool {
        var address = muteAddress
        guard isSettable(deviceID: deviceID, address: &address) else { return false }

        var mutableValue = value
        let status = AudioObjectSetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            UInt32(MemoryLayout<UInt32>.size),
            &mutableValue
        )
        return status == noErr
    }

    private func muteVolumeChannels(deviceID: AudioDeviceID) -> [VolumeState] {
        let elements: [AudioObjectPropertyElement] = [
            kAudioObjectPropertyElementMain,
            1,
            2,
        ]

        return elements.compactMap { element in
            guard let previous = readVolume(deviceID: deviceID, element: element),
                  setVolume(0, deviceID: deviceID, element: element) else {
                return nil
            }

            return VolumeState(element: element, value: previous)
        }
    }

    private func readVolume(deviceID: AudioDeviceID, element: AudioObjectPropertyElement) -> Float32? {
        var address = volumeAddress(element: element)
        guard isSettable(deviceID: deviceID, address: &address) else { return nil }

        var volume = Float32(0)
        var size = UInt32(MemoryLayout<Float32>.size)
        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &volume)
        guard status == noErr else { return nil }
        return volume
    }

    private func setVolume(
        _ value: Float32,
        deviceID: AudioDeviceID,
        element: AudioObjectPropertyElement
    ) -> Bool {
        var address = volumeAddress(element: element)
        guard isSettable(deviceID: deviceID, address: &address) else { return false }

        var mutableValue = value
        let status = AudioObjectSetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            UInt32(MemoryLayout<Float32>.size),
            &mutableValue
        )
        return status == noErr
    }

    private func isSettable(
        deviceID: AudioDeviceID,
        address: inout AudioObjectPropertyAddress
    ) -> Bool {
        guard AudioObjectHasProperty(deviceID, &address) else { return false }

        var settable = DarwinBoolean(false)
        let status = AudioObjectIsPropertySettable(deviceID, &address, &settable)
        return status == noErr && settable.boolValue
    }

    private var muteAddress: AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
    }

    private func volumeAddress(element: AudioObjectPropertyElement) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: element
        )
    }

    private struct RestoreState {
        let deviceID: AudioDeviceID
        let previousMute: UInt32?
        let previousVolumes: [VolumeState]
    }

    private struct VolumeState {
        let element: AudioObjectPropertyElement
        let value: Float32
    }
}
