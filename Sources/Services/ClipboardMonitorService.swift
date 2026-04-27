import Foundation
import AppKit

import Observation

/// Monitors the system clipboard (NSPasteboard) for changes while recording.
/// Only active between startMonitoring() and stopMonitoring() calls.
@MainActor
@Observable
final class ClipboardMonitorService {

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private(set) var items: [ClipboardItem] = []
    private var monitoringStartTime: Date = .distantPast

    /// Base directory to save all clipboard artifacts (images + text files)
    private let storageDir: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("Dikte/ClipboardAssets", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// Begin watching the clipboard. Called when recording starts.
    func startMonitoring() {
        items = []
        monitoringStartTime = Date()
        lastChangeCount = NSPasteboard.general.changeCount

        // Poll NSPasteboard every 0.3 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkClipboard()
            }
        }
        print("[Dikte] Clipboard izleme başladı")
    }

    /// Stop watching and return all captured items.
    func stopMonitoring() -> [ClipboardItem] {
        timer?.invalidate()
        timer = nil
        print("[Dikte] Clipboard izleme durdu. \(items.count) öğe yakalandı.")
        return items
    }

    // MARK: - Private

    /// Returns the name of the currently focused application (e.g. "Safari", "Ghostty")
    private func frontmostAppName() -> String? {
        NSWorkspace.shared.frontmostApplication?.localizedName
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        let now = Date()
        let sourceApp = frontmostAppName()

        // Check for image first (higher priority if both exist)
        if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
            if let item = saveImage(image, timestamp: now, sourceApp: sourceApp) {
                items.append(item)
                print("[Dikte] Görsel yakalandı [\(sourceApp ?? "?")]")
            }
        }
        // Check for string (URL or text)
        else if let string = pasteboard.string(forType: .string), !string.isEmpty {
            let isURL = string.hasPrefix("http://") || string.hasPrefix("https://")
            let item = saveText(string, isURL: isURL, timestamp: now, sourceApp: sourceApp)
            items.append(item)
            print("[Dikte] \(isURL ? "URL" : "Metin") yakalandı [\(sourceApp ?? "?")]")
        }
    }

    /// Saves text/URL content to a .txt file and returns a ClipboardItem with file path + size.
    private func saveText(_ content: String, isURL: Bool, timestamp: Date, sourceApp: String?) -> ClipboardItem {
        let fileName = "clipboard_\(UUID().uuidString).txt"
        let fileURL = storageDir.appendingPathComponent(fileName)
        var fileSize: Int64 = Int64(content.utf8.count)

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            let attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            fileSize = (attrs[.size] as? Int64) ?? fileSize
        } catch {
            print("[Dikte] Metin dosyası kaydedilemedi: \(error.localizedDescription)")
        }

        return ClipboardItem(
            id: UUID(),
            timestamp: timestamp,
            type: isURL ? .url : .text,
            textContent: content,
            imageFilePath: fileURL.path,
            sourceApp: sourceApp,
            fileSize: fileSize,
            relativeTime: timestamp.timeIntervalSince(monitoringStartTime)
        )
    }

    /// Saves an NSImage to disk and returns a ClipboardItem with file path + size.
    private func saveImage(_ image: NSImage, timestamp: Date, sourceApp: String?) -> ClipboardItem? {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            return nil
        }

        let fileName = "clipboard_\(UUID().uuidString).png"
        let fileURL = storageDir.appendingPathComponent(fileName)

        do {
            try pngData.write(to: fileURL)
            let attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            let fileSize = (attrs[.size] as? Int64) ?? Int64(pngData.count)

            return ClipboardItem(
                id: UUID(),
                timestamp: timestamp,
                type: .image,
                textContent: nil,
                imageFilePath: fileURL.path,
                sourceApp: sourceApp,
                fileSize: fileSize,
                relativeTime: timestamp.timeIntervalSince(monitoringStartTime)
            )
        } catch {
            print("[Dikte] Görsel kaydedilemedi: \(error.localizedDescription)")
            return nil
        }
    }
}
