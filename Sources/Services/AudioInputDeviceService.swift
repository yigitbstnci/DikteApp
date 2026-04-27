import Foundation
import CoreAudio

enum AudioInputDeviceService {
    struct Device: Sendable {
        let id: AudioDeviceID
        let name: String
        let uid: String
        let transportType: UInt32
    }

    static func preferredBuiltInInputDevice() -> Device? {
        let inputDevices = allInputDevices()
        let builtInDevices = inputDevices.filter { $0.transportType == kAudioDeviceTransportTypeBuiltIn }

        return builtInDevices.first { device in
            let normalizedName = device.name.lowercased()
            let normalizedUID = device.uid.lowercased()
            return normalizedUID.contains("builtinmicrophone")
                || normalizedName.contains("microphone")
                || normalizedName.contains("mikrofon")
        } ?? builtInDevices.first
    }

    static func setDefaultInputDevice(_ device: Device) throws {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = device.id
        let status = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            UInt32(MemoryLayout<AudioDeviceID>.size),
            &deviceID
        )

        guard status == noErr else {
            throw AudioInputDeviceError.defaultRouteFailed(device: device.name, status: status)
        }
    }

    static func defaultInputDevice() -> Device? {
        guard let deviceID = defaultInputDeviceID() else { return nil }
        return makeDevice(deviceID)
    }

    static func allInputDevices() -> [Device] {
        allDeviceIDs()
            .filter { inputStreamCount(for: $0) > 0 }
            .compactMap(makeDevice)
    }

    private static func allDeviceIDs() -> [AudioDeviceID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0

        guard AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size
        ) == noErr else {
            return []
        }

        let count = Int(size) / MemoryLayout<AudioDeviceID>.size
        var devices = [AudioDeviceID](repeating: 0, count: count)
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &devices
        )

        return status == noErr ? devices : []
    }

    private static func defaultInputDeviceID() -> AudioDeviceID? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
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

    private static func makeDevice(_ deviceID: AudioDeviceID) -> Device? {
        guard let name = stringProperty(deviceID, selector: kAudioDevicePropertyDeviceNameCFString),
              let uid = stringProperty(deviceID, selector: kAudioDevicePropertyDeviceUID),
              let transportType = uint32Property(deviceID, selector: kAudioDevicePropertyTransportType) else {
            return nil
        }

        return Device(
            id: deviceID,
            name: name,
            uid: uid,
            transportType: transportType
        )
    }

    private static func inputStreamCount(for deviceID: AudioDeviceID) -> Int {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &size)
        guard status == noErr else { return 0 }
        return Int(size) / MemoryLayout<AudioStreamID>.size
    }

    private static func stringProperty(
        _ deviceID: AudioDeviceID,
        selector: AudioObjectPropertySelector
    ) -> String? {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let valuePointer = UnsafeMutablePointer<CFString?>.allocate(capacity: 1)
        valuePointer.initialize(to: nil)
        defer {
            valuePointer.deinitialize(count: 1)
            valuePointer.deallocate()
        }

        var size = UInt32(MemoryLayout<CFString?>.size)
        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, valuePointer)
        guard status == noErr, let value = valuePointer.pointee else { return nil }
        return value as String
    }

    private static func uint32Property(
        _ deviceID: AudioDeviceID,
        selector: AudioObjectPropertySelector
    ) -> UInt32? {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var value = UInt32(0)
        var size = UInt32(MemoryLayout<UInt32>.size)
        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &value)
        return status == noErr ? value : nil
    }
}

enum AudioInputDeviceError: LocalizedError {
    case builtInInputUnavailable(defaultInputName: String?)
    case defaultRouteFailed(device: String, status: OSStatus)

    var errorDescription: String? {
        switch self {
        case let .builtInInputUnavailable(defaultInputName):
            let current = defaultInputName.map { " Şu anki default input: \($0)." } ?? ""
            return "MacBook mikrofonu bulunamadı.\(current)"
        case let .defaultRouteFailed(device, status):
            return "\(device) varsayılan mikrofon olarak seçilemedi. CoreAudio status: \(status)."
        }
    }
}
