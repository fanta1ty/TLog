import Foundation

/// Built-in filters
public struct TLogFilters {
    /// Filter by category
    public static func category(_ categories: Set<String>) -> TLogFilter {
        TLogCategoryFilter(allowedCategories: categories)
    }
    
    /// Filter by message content
    public static func contains(_ text: String, caseSensitive: Bool = false) -> TLogFilter {
        TLogContentFilter(searchText: text, caseSensitive: caseSensitive)
    }
    
    /// Filter by time interval
    public static func timeInterval(_ interval: TimeInterval) -> TLogFilter {
        TLogTimeIntervalFilter(interval: interval)
    }
    
    /// Rate limiting filter
    public static func rateLimit(maxMessages: Int, per timeWindow: TimeInterval) -> TLogFilter {
        TLogRateLimitFilter(maxMessages: maxMessages, timeWindow: timeWindow)
    }
}

// MARK: - TLogCategoryFilter
private struct TLogCategoryFilter: TLogFilter {
    let allowedCategories: Set<String>
    func shouldLog(_ message: TLogMessage) -> Bool {
        allowedCategories.contains(message.category)
    }
}

// MARK: - TLogContentFilter
private struct TLogContentFilter: TLogFilter {
    let searchText: String
    let caseSensitive: Bool
    func shouldLog(_ message: TLogMessage) -> Bool {
        if caseSensitive {
            return message.message.contains(searchText)
        } else {
            return message.message.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - TLogTimeIntervalFilter
private struct TLogTimeIntervalFilter: TLogFilter {
    let interval: TimeInterval
    private let startTime = Date()
    func shouldLog(_ message: TLogMessage) -> Bool {
        return message.timestamp.timeIntervalSince(startTime) <= interval
    }
}

// MARK: - TLogRateLimitFilter
private class TLogRateLimitFilter: TLogFilter {
    private let maxMessages: Int
    private let timeWindow: TimeInterval
    private var messageTimestamps: [Date] = []
    private let queue = DispatchQueue(label: "rateLimit", attributes: .concurrent)
    
    init(maxMessages: Int, timeWindow: TimeInterval) {
        self.maxMessages = maxMessages
        self.timeWindow = timeWindow
    }
    
    func shouldLog(_ message: TLogMessage) -> Bool {
        return queue.sync {
            let now = Date()
            let cutoff = now.addingTimeInterval(-timeWindow)
            
            // Remove old timestamps
            messageTimestamps.removeAll { $0 < cutoff }
            
            // Check if we can add another message
            if messageTimestamps.count < maxMessages {
                messageTimestamps.append(now)
                return true
            }
            return false
        }
    }
}
