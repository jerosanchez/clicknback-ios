//

import Foundation

public final class ConsoleLogger: Logger {
    private let dateFormatter: DateFormatter

    public init(dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS") {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
    }

    public func debug(_ message: String) {
        log(level: .debug, message: message)
    }

    public func info(_ message: String) {
        log(level: .info, message: message)
    }

    public func warning(_ message: String) {
        log(level: .warning, message: message)
    }

    public func error(_ message: String) {
        log(level: .error, message: message)
    }

    // MARK: - Helper methods

    private func log(level: LogLevel, message: String) {
        let timestamp = dateFormatter.string(from: Date())
        let formatted = "\(level.emoji) [\(timestamp)] [\(level.rawValue.uppercased())] \(message)"
        print(formatted)
    }
}
