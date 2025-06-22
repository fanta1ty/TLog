import Foundation
import OSLog

/// Represents different logging levels with proper hierarchy
public enum TLogLevel: Int, CaseIterable {
    case trace      = 0
    case debug      = 1
    case info       = 2
    case warning    = 3
    case error      = 4
    case critical   = 5
    
    /// String representation of the log level
    public var description: String {
        switch self {
        case .trace:    return "TRACE"
        case .debug:    return "DEBUG"
        case .info:     return "INFO"
        case .warning:  return "WARNING"
        case .error:    return "ERROR"
        case .critical: return "CRITICAL"
        }
    }
    
    /// Emoji representation for better visual distinction
    public var emoji: String {
        switch self {
        case .trace:    return "🔍"
        case .debug:    return "🐛"
        case .info:     return "ℹ️"
        case .warning:  return "⚠️"
        case .error:    return "❌"
        case .critical: return "🔥"
        }
    }
    
    /// OSLog type mapping
    @available(iOS 10.0, *)
    public var osLogType: OSLogType {
        switch self {
        case .trace, .debug:    return .debug
        case .info:             return .info
        case .warning:          return .default
        case .error:            return .error
        case .critical:         return .fault
        }
    }
}

// MARK: - Comparable
extension TLogLevel: Comparable {
    public static func < (lhs: TLogLevel, rhs: TLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
