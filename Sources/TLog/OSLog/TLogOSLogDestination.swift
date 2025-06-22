import Foundation
import os.log

@available(iOS 10.0, *)
public class TLogOSLogDestination: TLogDestination {
    public var isEnabled: Bool = true
    public var minimumLevel: TLogLevel = .trace
    public var filters: [TLogFilter] = []
    public var formatter: TLogFormatter?
    
    private let osLog: OSLog
    
    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.default", category: String = "general") {
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    public func write(_ message: TLogMessage) {
        guard isEnabled && message.level >= minimumLevel else { return }
        guard filters.allSatisfy({ $0.shouldLog(message) }) else { return }
        
        let formattedMessage = formatter?.format(message) ?? message.formattedMessage
        os_log("%{public}@", log: osLog, type: message.level.osLogType, formattedMessage)
    }
}
