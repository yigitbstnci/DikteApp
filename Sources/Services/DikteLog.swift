import Foundation

enum DikteLog {
    typealias Metadata = [String: Any]

    enum Level: String {
        case action = "ACTION"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"

        var compactCode: String {
            switch self {
            case .action:
                return "ACT"
            case .info:
                return "INF"
            case .warning:
                return "WRN"
            case .error:
                return "ERR"
            }
        }

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
        formatter.locale = Locale(identifier: "en_US_POSIX")
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

    static func action(_ area: String, _ event: String, _ message: String, metadata: Metadata = [:]) {
        write(.action, area: area, event: event, message: message, metadata: metadata)
    }

    static func info(_ area: String, _ event: String, _ message: String, metadata: Metadata = [:]) {
        write(.info, area: area, event: event, message: message, metadata: metadata)
    }

    static func warning(_ area: String, _ event: String, _ message: String, metadata: Metadata = [:]) {
        write(.warning, area: area, event: event, message: message, metadata: metadata)
    }

    static func error(_ area: String, _ event: String, _ message: String, metadata: Metadata = [:]) {
        write(.error, area: area, event: event, message: message, metadata: metadata)
    }

    static func metadata(_ values: Metadata = [:], sessionID: String?) -> Metadata {
        var metadata = values
        if let sessionID {
            metadata["session"] = sessionID
        }
        return metadata
    }

    static func makeLine(
        timestamp: Date,
        level: Level,
        area: String,
        event: String,
        message: String,
        metadata: Metadata = [:]
    ) -> String {
        let target = "\(area).\(event)"
        let message = sanitizeMessage(message)
        let metadata = renderMetadata(metadata)
        let prefix = [
            formatter.string(from: timestamp),
            level.compactCode,
            target
        ].joined(separator: " ")

        if !message.isEmpty, !metadata.isEmpty {
            return "\(prefix) | \(message) | \(metadata)"
        }

        if !message.isEmpty {
            return "\(prefix) | \(message)"
        }

        if !metadata.isEmpty {
            return "\(prefix) | \(metadata)"
        }

        return prefix
    }

    private static func write(
        _ level: Level,
        area: String,
        event: String,
        message: String,
        metadata: Metadata
    ) {
        lock.lock()
        defer { lock.unlock() }

        let line = makeLine(
            timestamp: Date(),
            level: level,
            area: area,
            event: event,
            message: message,
            metadata: metadata
        )

        let rendered = usesANSIColors ? "\(level.ansiColor)\(line)\(reset)" : line
        FileHandle.standardOutput.write(Data((rendered + "\n").utf8))
        appendToLogFile(line)
    }

    private static func sanitizeMessage(_ message: String) -> String {
        message
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func renderMetadata(_ metadata: Metadata) -> String {
        metadata
            .filter { !$0.key.isEmpty }
            .sorted { $0.key < $1.key }
            .map { "\(sanitizeKey($0.key))=\(renderValue($0.value))" }
            .joined(separator: " ")
    }

    private static func sanitizeKey(_ key: String) -> String {
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")
        return key
            .unicodeScalars
            .map { allowed.contains($0) ? Character($0) : "_" }
            .reduce(into: "") { $0.append($1) }
    }

    private static func renderValue(_ value: Any) -> String {
        let text: String
        switch value {
        case let value as Bool:
            text = value ? "true" : "false"
        case let value as URL:
            text = value.path
        case let value as CustomStringConvertible:
            text = value.description
        default:
            text = String(describing: value)
        }

        guard shouldQuote(text) else { return text }
        return "\"\(escapeQuotedValue(text))\""
    }

    private static func shouldQuote(_ text: String) -> Bool {
        text.isEmpty || text.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) != nil
            || text.contains("\"")
            || text.contains("=")
            || text.contains("|")
    }

    private static func escapeQuotedValue(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
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
