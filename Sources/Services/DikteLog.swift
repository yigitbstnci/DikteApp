import Foundation

enum DikteLog {
    enum Level: String {
        case action = "ACTION"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"

        var marker: String {
            switch self {
            case .warning, .error:
                return "!!"
            case .action, .info:
                return "--"
            }
        }

        var ansiColor: String {
            switch self {
            case .action:
                return "\u{001B}[38;5;111m"
            case .info:
                return "\u{001B}[38;5;245m"
            case .warning:
                return "\u{001B}[38;5;214m"
            case .error:
                return "\u{001B}[38;5;203m"
            }
        }
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    private static let lock = NSLock()
    private static let reset = "\u{001B}[0m"
    private static let fileURL: URL = {
        let logsDirectory = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/Dikte", isDirectory: true)
        try? FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        return logsDirectory.appendingPathComponent("dikte.log")
    }()

    static func action(_ area: String, _ event: String, _ message: String) {
        write(.action, area: area, event: event, message: message)
    }

    static func info(_ area: String, _ event: String, _ message: String) {
        write(.info, area: area, event: event, message: message)
    }

    static func warning(_ area: String, _ event: String, _ message: String) {
        write(.warning, area: area, event: event, message: message)
    }

    static func error(_ area: String, _ event: String, _ message: String) {
        write(.error, area: area, event: event, message: message)
    }

    private static func write(_ level: Level, area: String, event: String, message: String) {
        lock.lock()
        defer { lock.unlock() }

        let timestamp = formatter.string(from: Date())
        let line = [
            timestamp,
            pad(level.marker, to: 2),
            pad(level.rawValue, to: 8),
            pad(area, to: 10),
            pad(event, to: 28),
            message
        ].joined(separator: "  ")

        let rendered = usesANSIColors ? "\(level.ansiColor)\(line)\(reset)" : line
        FileHandle.standardOutput.write(Data((rendered + "\n").utf8))
        appendToLogFile(line)
    }

    private static func pad(_ value: String, to width: Int) -> String {
        if value.count >= width { return value }
        return value + String(repeating: " ", count: width - value.count)
    }

    private static var usesANSIColors: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["DIKTE_LOG_STYLE"] == "terminal"
            && environment["DIKTE_LOG_COLOR"] != "0"
    }

    private static func appendToLogFile(_ line: String) {
        let data = Data((line + "\n").utf8)

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }

        guard let handle = try? FileHandle(forWritingTo: fileURL) else { return }
        defer {
            try? handle.close()
        }

        do {
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
        } catch {
            // Avoid recursive logging from the logging subsystem.
        }
    }
}
