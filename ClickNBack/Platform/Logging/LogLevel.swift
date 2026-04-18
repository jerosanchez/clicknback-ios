//

import Foundation

public enum LogLevel: String {
    case debug
    case info
    case warning
    case error

    public var emoji: String {
        switch self {
        case .debug: "🔵"
        case .info: "🟢"
        case .warning: "🟡"
        case .error: "🔴"
        }
    }
}
