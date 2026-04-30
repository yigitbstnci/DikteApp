import Foundation

@MainActor
final class AudioInputRouteService {
    private var previousDefaultInput: AudioInputDeviceService.Device?

    func routeToBuiltInForRecording(sessionID: String? = nil) throws {
        guard previousDefaultInput == nil else { return }

        previousDefaultInput = AudioInputDeviceService.defaultInputDevice()

        guard let builtIn = AudioInputDeviceService.preferredBuiltInInputDevice() else {
            throw AudioInputDeviceError.builtInInputUnavailable(
                defaultInputName: previousDefaultInput?.name
            )
        }

        if previousDefaultInput?.id == builtIn.id {
            DikteLog.action("audio", "inputRoute.selected", "\(builtIn.name) zaten varsayılan giriş cihazı.", metadata: DikteLog.metadata([
                "device_id": builtIn.id,
                "device_uid": builtIn.uid,
                "transport": builtIn.transportType
            ], sessionID: sessionID))
            return
        }

        try AudioInputDeviceService.setDefaultInputDevice(builtIn)
        DikteLog.action("audio", "inputRoute.selected", "\(builtIn.name) kayıt için varsayılan giriş yapıldı.", metadata: DikteLog.metadata([
            "device_id": builtIn.id,
            "device_uid": builtIn.uid,
            "previous": previousDefaultInput?.name ?? "-",
            "transport": builtIn.transportType
        ], sessionID: sessionID))
    }

    func restoreDefaultInput(sessionID: String? = nil) {
        defer { previousDefaultInput = nil }

        guard let previousDefaultInput else { return }
        guard let currentDefault = AudioInputDeviceService.defaultInputDevice() else { return }
        guard currentDefault.id != previousDefaultInput.id else { return }

        do {
            try AudioInputDeviceService.setDefaultInputDevice(previousDefaultInput)
            DikteLog.action("audio", "inputRoute.restored", "\(previousDefaultInput.name) varsayılan giriş olarak geri alındı.", metadata: DikteLog.metadata([
                "current": currentDefault.name,
                "restored_device_id": previousDefaultInput.id
            ], sessionID: sessionID))
        } catch {
            DikteLog.warning("audio", "inputRoute.restoreFailed", error.localizedDescription, metadata: DikteLog.metadata([
                "target": previousDefaultInput.name
            ], sessionID: sessionID))
        }
    }
}
