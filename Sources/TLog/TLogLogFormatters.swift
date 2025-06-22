import Foundation

public struct TLogFormatters {
    /// Simple formatter with basic information
    public static let simple = TLogSimpleFormatter()
    
    /// Detailed formatter with all metadata
    public static let detailed = TLogDetailedFormatter()
    
    /// JSON formatter for structured logging
    public static let json = TLogJSONFormatter()
    
    /// Custom formatter
    public static func custom(_ format: @escaping (TLogMessage) -> String) -> TLogFormatter {
        TLogCustomFormatter(format: format)
    }
}

// MARK: - TLogSimpleFormatter
public struct TLogSimpleFormatter: TLogFormatter {
    public func format(_ message: TLogMessage) -> String {
        return "\(message.level.description): \(message.message)"
    }
}

// MARK: - TLogDetailedFormatter
public struct TLogDetailedFormatter: TLogFormatter {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    public func format(_ message: TLogMessage) -> String {
        let timestamp = dateFormatter.string(from: message.timestamp)
        let thread = message.threadInfo.isMainThread ? "main" : "bg(\(message.threadInfo.number))"
        return "\(timestamp) [\(message.level.description)] [\(message.category)] [\(thread)] <\(message.file):\(message.line)> \(message.formattedMessage)"
    }
}

// MARK: - TLogJSONFormatter
public struct TLogJSONFormatter: TLogFormatter {
    public func format(_ message: TLogMessage) -> String {
        let json: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: message.timestamp),
            "level": message.level.description,
            "message": message.message,
            "category": message.category,
            "file": message.file,
            "line": message.line,
            "thread": [
                "name": message.threadInfo.name ?? "",
                "number": message.threadInfo.number,
                "isMain": message.threadInfo.isMainThread
            ],
            "metadata": message.metadata.mapValues { $0.description }
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: json),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return message.message
    }
}

// MARK: - TLogCustomFormatter
private struct TLogCustomFormatter: TLogFormatter {
    let format: (TLogMessage) -> String
    func format(_ message: TLogMessage) -> String { format(message) }
}
