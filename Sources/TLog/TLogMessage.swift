import Foundation

/// Represents a complete log message with metadata
public struct TLogMessage {
    public let level: TLogLevel
    public let message: String
    public let timestamp: Date
    public let file: String
    public let function: String
    public let line: Int
    public let category: String
    public let metadata: TLogMetadata
    public let threadInfo: TLogThreadInfo
    
    // Thread information
    public struct TLogThreadInfo {
        public let name: String?
        public let number: Int
        public let isMainThread: Bool
        
        init() {
            self.name = Thread.current.name
            self.number = Thread.current.isMainThread ? 1 : Int(pthread_mach_thread_np(pthread_self()))
            self.isMainThread = Thread.current.isMainThread
        }
    }
    
    init(
        level: TLogLevel,
        message: String,
        category: String,
        metadata: TLogMetadata,
        file: String,
        function: String,
        line: Int
    ) {
        self.level = level
        self.message = message
        self.timestamp = Date()
        self.file = URL(fileURLWithPath: file).lastPathComponent
        self.function = function
        self.line = line
        self.category = category
        self.metadata = metadata
        self.threadInfo = TLogThreadInfo()
    }
    
    /// Format message with interpolated metadata
    public var formattedMessage: String {
        guard !metadata.isEmpty else { return message }
        
        let metadataString = metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
        return "\(message) [\(metadataString)]"
    }
}
