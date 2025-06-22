import Foundation

/// In-memory destination for testing and debugging
public class MemoryDestination: TLogDestination {
    public var isEnabled: Bool = true
    public var minimumLevel: TLogLevel = .trace
    public var filters: [TLogFilter] = []
    public var formatter: TLogFormatter?
    
    public private(set) var messages: [TLogMessage] = []
    public var maxMessages: Int = 1000
    
    private let queue = DispatchQueue(label: "com.tlog.memory", attributes: .concurrent)
    
    public init(maxMessages: Int = 1000) {
        self.maxMessages = maxMessages
    }
    
    public func write(_ message: TLogMessage) {
        guard isEnabled && message.level >= minimumLevel else { return }
        guard filters.allSatisfy({ $0.shouldLog(message) }) else { return }
        
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.messages.append(message)
            
            // Remove old messages if we exceed the limit
            if self.messages.count > self.maxMessages {
                self.messages.removeFirst(self.messages.count - self.maxMessages)
            }
        }
    }
    
    /// Get all messages (thread-safe)
    public func getAllMessages() -> [TLogMessage] {
        return queue.sync { messages }
    }
    
    /// Clear all messages
    public func clear() {
        queue.async(flags: .barrier) { [weak self] in
            self?.messages.removeAll()
        }
    }
    
    /// Search messages
    public func search(text: String, caseSensitive: Bool = false) -> [TLogMessage] {
        return queue.sync {
            messages.filter { message in
                if caseSensitive {
                    return message.message.contains(text)
                } else {
                    return message.message.localizedCaseInsensitiveContains(text)
                }
            }
        }
    }
    
    /// Get messages by level
    public func getMessages(for level: TLogLevel) -> [TLogMessage] {
        return queue.sync {
            messages.filter { $0.level == level }
        }
    }
    
    /// Get messages by category
    public func getMessages(for category: String) -> [TLogMessage] {
        return queue.sync {
            messages.filter { $0.category == category }
        }
    }
}
