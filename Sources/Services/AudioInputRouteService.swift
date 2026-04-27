import Foundation

@MainActor
final class AudioInputRouteService {
    private var previousDefaultInput: AudioInputDeviceService.Device?

    func routeToBuiltInForRecording() throws {
        guard previousDefaultInput == nil else { return }

        previousDefaultInput = AudioInputDeviceService.defaultInputDevice()

        guard let builtIn = AudioInputDeviceService.preferredBuiltInInputDevice() else {
            throw AudioInputDeviceError.builtInInputUnavailable(
                defaultInputName: previousDefaultInput?.name
            )
        }

        if previousDefaultInput?.id == builtIn.id {
            DikteLog.action("audio", "inputRoute.selected", "\(builtIn.name) zaten varsayılan giriş cihazı.")
            return
        }

        try AudioInputDeviceService.setDefaultInputDevice(builtIn)
        DikteLog.action("audio", "inputRoute.selected", "\(builtIn.name) kayıt için varsayılan giriş yapıldı.")
    }

    func restoreDefaultInput() {
        defer { previousDefaultInput = nil }

        guard let previousDefaultInput else { return }
        guard let currentDefault = AudioInputDeviceService.defaultInputDevice() else { return }
        guard currentDefault.id != previousDefaultInput.id else { return }

        do {
            try AudioInputDeviceService.setDefaultInputDevice(previousDefaultInput)
            DikteLog.action("audio", "inputRoute.restored", "\(previousDefaultInput.name) varsayılan giriş olarak geri alındı.")
        } catch {
            DikteLog.warning("audio", "inputRoute.restoreFailed", error.localizedDescription)
        }
    }
}
