import Foundation
import AppKit

/// Monitors the system clipboard (NSPasteboard) for changes while recording.
/// Only active between startMonitoring() and stopMonitoring() calls.
@MainActor
final class ClipboardMonitorService {

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private var capturedItems: [ClipboardItem] = []
    private var monitoringStartTime: Date = .distantPast

    /// Directory to save clipboard images
    private let imageStorageDir: URL = {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("dikte_clipboard_images", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// Begin watching the clipboard. Called when recording starts.
    func startMonitoring() {
        capturedItems = []
        monitoringStartTime = Date()
        lastChangeCount = NSPasteboard.general.changeCount

        // Poll NSPasteboard every 0.3 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkClipboard()
            }
        }
        print("📋 Clipboard monitoring started")
    }

    /// Stop watching and return all captured items.
    func stopMonitoring() -> [ClipboardItem] {
        timer?.invalidate()
        timer = nil
        print("📋 Clipboard monitoring stopped. Captured \(capturedItems.count) item(s).")
        return capturedItems
    }

    // MARK: - Private

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        let now = Date()

        // Check for image first (higher priority if both exist)
        if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
            if let item = saveImage(image, timestamp: now) {
                capturedItems.append(item)
                print("📋 Captured image at \(now)")
            }
        }
        // Check for string (URL or text)
        else if let string = pasteboard.string(forType: .string), !string.isEmpty {
            let isURL = string.hasPrefix("http://") || string.hasPrefix("https://")
            let item = ClipboardItem(
                id: UUID(),
                timestamp: now,
                type: isURL ? .url : .text,
                textContent: string,
                imageFilePath: nil,
                relativeTime: now.timeIntervalSince(monitoringStartTime)
            )
            capturedItems.append(item)
            print("📋 Captured \(isURL ? "URL" : "text") at \(now): \(string.prefix(80))...")
        }
    }

    /// Saves an NSImage to disk and returns a ClipboardItem pointing to it.
    private func saveImage(_ image: NSImage, timestamp: Date) -> ClipboardItem? {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            return nil
        }

        let fileName = "clipboard_\(UUID().uuidString).png"
        let fileURL = imageStorageDir.appendingPathComponent(fileName)

        do {
            try pngData.write(to: fileURL)
            return ClipboardItem(
                id: UUID(),
                timestamp: timestamp,
                type: .image,
                textContent: nil,
                imageFilePath: fileURL.path,
                relativeTime: timestamp.timeIntervalSince(monitoringStartTime)
            )
        } catch {
            print("❌ Failed to save clipboard image: \(error)")
            return nil
        }
    }
}
