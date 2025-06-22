import Foundation

/// Console output destination with formatting options
public class TLogConsoleDestination: TLogDestination {
    public var isEnabled: Bool = true
    public var minimumLevel: TLogLevel = .trace
    public var filters: [TLogFilter] = []
    public var formatter: TLogFormatter?
    
    public var showEmojis: Bool = true
    public var showTimestamp: Bool = true
    public var showCategory: Bool = true
    public var showLocation: Bool = true
    public var showThreadInfo: Bool = false
    public var colorOutput: Bool = true
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    public init() {}
    
    public func write(_ message: TLogMessage) {
        guard isEnabled && message.level >= minimumLevel else { return }
        guard filters.allSatisfy({ $0.shouldLog(message) }) else { return }
        
        let output = formatter?.format(message) ?? defaultFormat(message)
        print(colorOutput ? colorize(output, for: message.level) : output)
    }
    
    private func defaultFormat(_ message: TLogMessage) -> String {
        var components: [String] = []
        
        if showTimestamp {
            components.append(dateFormatter.string(from: message.timestamp))
        }
        
        if showEmojis {
            components.append(message.level.emoji)
        }
        
        components.append("[\(message.level.description)]")
        
        if showCategory {
            components.append("[\(message.category)]")
        }
        
        if showThreadInfo {
            let threadName = message.threadInfo.isMainThread ? "main" : "bg(\(message.threadInfo.number))"
            components.append("[\(threadName)]")
        }
        
        if showLocation {
            components.append("<\(message.file):\(message.line)>")
        }
        
        components.append(message.formattedMessage)
        
        return components.joined(separator: " ")
    }
    
    private func colorize(_ text: String, for level: TLogLevel) -> String {
        let colorCode: String
        switch level {
        case .trace: colorCode = "\u{001B}[0;37m"     // Light gray
        case .debug: colorCode = "\u{001B}[0;36m"     // Cyan
        case .info: colorCode = "\u{001B}[0;32m"      // Green
        case .warning: colorCode = "\u{001B}[0;33m"   // Yellow
        case .error: colorCode = "\u{001B}[0;31m"     // Red
        case .critical: colorCode = "\u{001B}[0;35m"  // Magenta
        }
        let resetCode = "\u{001B}[0m"
        return "\(colorCode)\(text)\(resetCode)"
    }
}
