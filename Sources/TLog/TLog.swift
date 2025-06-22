import Foundation

public final class TLog {
    
    // MARK: - Singleton
    
    public static let shared = TLog()
    
    // MARK: - Properties
    
    private var destinations: [TLogDestination] = []
    private let queue = DispatchQueue(label: "com.tlog.main", qos: .utility)
    
    /// Global enable/disable flag
    public var isEnabled: Bool = true
    
    /// Minimum log level for all destinations
    public var minimumLevel: TLogLevel = .trace
    
    /// Default category for logs
    public var defaultCategory: String = "APP"
    
    /// Global metadata that will be attached to all log messages
    public var globalMetadata: TLogMetadata = [:]
    
    /// Performance monitoring
    public var isPerformanceMonitoringEnabled: Bool = false
    private var _performanceMetrics = TLogPerformanceMetrics()
    
    /// Configuration profiles for different environments
    public enum TLogEnvironment {
        case development
        case testing
        case staging
        case production
        
        var configuration: TLogConfiguration {
            switch self {
            case .development:
                return TLogConfiguration(
                    minimumLevel: .trace,
                    enableFileLogging: true,
                    enableConsoleColors: true,
                    showThreadInfo: true,
                    enablePerformanceMonitoring: true
                )
            case .testing:
                return TLogConfiguration(
                    minimumLevel: .debug,
                    enableFileLogging: false,
                    enableConsoleColors: false,
                    showThreadInfo: false,
                    enablePerformanceMonitoring: false
                )
            case .staging:
                return TLogConfiguration(
                    minimumLevel: .info,
                    enableFileLogging: true,
                    enableConsoleColors: false,
                    showThreadInfo: false,
                    enablePerformanceMonitoring: false
                )
            case .production:
                return TLogConfiguration(
                    minimumLevel: .warning,
                    enableFileLogging: true,
                    enableConsoleColors: false,
                    showThreadInfo: false,
                    enablePerformanceMonitoring: false
                )
            }
        }
    }
    
    // MARK: - Configuration
    
    public struct TLogConfiguration {
        public let minimumLevel: TLogLevel
        public let enableFileLogging: Bool
        public let enableConsoleColors: Bool
        public let showThreadInfo: Bool
        public let enablePerformanceMonitoring: Bool
        
        public init(
            minimumLevel: TLogLevel = .trace,
            enableFileLogging: Bool = false,
            enableConsoleColors: Bool = true,
            showThreadInfo: Bool = false,
            enablePerformanceMonitoring: Bool = false
        ) {
            self.minimumLevel = minimumLevel
            self.enableFileLogging = enableFileLogging
            self.enableConsoleColors = enableConsoleColors
            self.showThreadInfo = showThreadInfo
            self.enablePerformanceMonitoring = enablePerformanceMonitoring
        }
    }
    
    // MARK: - Performance Metrics
    
    public struct TLogPerformanceMetrics {
        public private(set) var messagesLogged: Int = 0
        public private(set) var averageLogTime: TimeInterval = 0
        public private(set) var totalLogTime: TimeInterval = 0
        public private(set) var messagesByLevel: [TLogLevel: Int] = [:]
        
        mutating func recordLogTime(_ time: TimeInterval, for level: TLogLevel) {
            messagesLogged += 1
            totalLogTime += time
            averageLogTime = totalLogTime / TimeInterval(messagesLogged)
            messagesByLevel[level, default: 0] += 1
        }
        
        public mutating func reset() {
            var metrics = TLogPerformanceMetrics()
            self = metrics
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        setupDefaultDestinations()
    }
    
    private func setupDefaultDestinations() {
        // Add console destination by default
        addDestination(TLogConsoleDestination())
        
        // Add OSLog destination on iOS 10+
        if #available(iOS 10.0, *) {
            addDestination(TLogOSLogDestination())
        }
    }
    
    // MARK: - Configuration Methods
    
    /// Configure TLog for specific environment
    public func configure(for environment: TLogEnvironment) {
        let config = environment.configuration
        
        minimumLevel = config.minimumLevel
        isPerformanceMonitoringEnabled = config.enablePerformanceMonitoring
        
        // Configure existing destinations
        for destination in destinations {
            if let console = destination as? TLogConsoleDestination {
                console.colorOutput = config.enableConsoleColors
                console.showThreadInfo = config.showThreadInfo
            }
        }
        
        // Add file logging if needed
        if config.enableFileLogging {
            enableFileLogging()
        }
    }
    
    /// Apply custom configuration
    public func configure(with configuration: TLogConfiguration) {
        minimumLevel = configuration.minimumLevel
        isPerformanceMonitoringEnabled = configuration.enablePerformanceMonitoring
        
        for destination in destinations {
            if let console = destination as? TLogConsoleDestination {
                console.colorOutput = configuration.enableConsoleColors
                console.showThreadInfo = configuration.showThreadInfo
            }
        }
        
        if configuration.enableFileLogging {
            enableFileLogging()
        }
    }
    
    // MARK: - Destination Management
    
    /// Add a log destination
    public func addDestination(_ destination: TLogDestination) {
        queue.async {
            self.destinations.append(destination)
        }
    }
    
    /// Remove all destinations
    public func removeAllDestinations() {
        queue.async {
            self.destinations.removeAll()
        }
    }
    
    /// Add file logging with default configuration
    public func enableFileLogging(fileName: String = "app.log") {
        addDestination(TLogFileDestination(fileName: fileName))
    }
    
    // MARK: - Logging Methods
    
    private func log(
        level: TLogLevel,
        message: String,
        metadata: TLogMetadata = [:],
        category: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard isEnabled && level >= minimumLevel else { return }
        
        let startTime = isPerformanceMonitoringEnabled ? CFAbsoluteTimeGetCurrent() : 0
        
        // Merge global metadata with message-specific metadata
        var combinedMetadata = globalMetadata
        for (key, value) in metadata {
            combinedMetadata[key] = value
        }
        
        let logMessage = TLogMessage(
            level: level,
            message: message,
            category: category ?? defaultCategory,
            metadata: combinedMetadata,
            file: file,
            function: function,
            line: line
        )
        
        queue.async {
            for destination in self.destinations {
                destination.write(logMessage)
            }
            
            // Record performance metrics
            if self.isPerformanceMonitoringEnabled {
                let endTime = CFAbsoluteTimeGetCurrent()
                let logTime = endTime - startTime
                self._performanceMetrics.recordLogTime(logTime, for: level)
            }
        }
    }
    
    // MARK: - Public Logging API with Metadata Support
    
    /// Log trace message - finest level of detail
    public func trace(
        _ message: String,
        metadata: TLogMetadata = [:],
        category: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .trace, message: message, metadata: metadata, category: category, file: file, function: function, line: line)
    }
    
    /// Log debug message - detailed information for debugging
    public func debug(
        _ message: String,
        metadata: TLogMetadata = [:],
        category: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .debug, message: message, metadata: metadata, category: category, file: file, function: function, line: line)
    }
    
    /// Log info message - general information
    public func info(
        _ message: String,
        metadata: TLogMetadata = [:],
        category: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .info, message: message, metadata: metadata, category: category, file: file, function: function, line: line)
    }
    
    /// Log warning message - potentially harmful situations
    public func warning(
        _ message: String,
        metadata: TLogMetadata = [:],
        category: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .warning, message: message, metadata: metadata, category: category, file: file, function: function, line: line)
    }
    
    /// Log error message - error events
    public func error(
        _ message: String,
        metadata: TLogMetadata = [:],
        category: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .error, message: message, metadata: metadata, category: category, file: file, function: function, line: line)
    }
    
    /// Log critical message - very severe error events
    public func critical(
        _ message: String,
        metadata: TLogMetadata = [:],
        category: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .critical, message: message, metadata: metadata, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Convenience Logging Methods
    
    /// Log with automatic error extraction
    public func error(_ error: Error, message: String = "Error occurred", category: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let metadata: TLogMetadata = [
            "error_type": .string(String(describing: type(of: error))),
            "error_description": .string(error.localizedDescription),
            "error_code": .stringConvertible((error as NSError).code)
        ]
        
        log(level: .error, message: message, metadata: metadata, category: category, file: file, function: function, line: line)
    }
    
    /// Log function entry/exit for debugging
    public func trace(function: String = #function, file: String = #file, line: Int = #line) {
        trace("→ \(function)", category: "TRACE", file: file, function: function, line: line)
    }
    
    /// Log function exit
    public func traceExit(function: String = #function, file: String = #file, line: Int = #line) {
        trace("← \(function)", category: "TRACE", file: file, function: function, line: line)
    }
    
    /// Log execution time
    public func time<T>(_ operation: String, category: String? = nil, block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let executionTime = CFAbsoluteTimeGetCurrent() - startTime
            debug("⏱ \(operation) took \(String(format: "%.3f", executionTime * 1000))ms",
                  metadata: ["execution_time_ms": .stringConvertible(executionTime * 1000)],
                  category: category ?? "PERFORMANCE")
        }
        return try block()
    }
    
    /// Log async execution time
    public func timeAsync<T>(_ operation: String, category: String? = nil, block: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let executionTime = CFAbsoluteTimeGetCurrent() - startTime
            debug("⏱ \(operation) took \(String(format: "%.3f", executionTime * 1000))ms",
                  metadata: ["execution_time_ms": .stringConvertible(executionTime * 1000)],
                  category: category ?? "PERFORMANCE")
        }
        return try await block()
    }
    
    // MARK: - Static Convenience Methods (Backward Compatibility)
    
    /// Backward compatibility - enable/disable logging
    public static var isLoggingEnabled: Bool {
        get { shared.isEnabled }
        set { shared.isEnabled = newValue }
    }
    
    /// Static debug logging method
    public static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.debug(message, file: file, function: function, line: line)
    }
    
    /// Static info logging method
    public static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.info(message, file: file, function: function, line: line)
    }
    
    /// Static warning logging method
    public static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.warning(message, file: file, function: function, line: line)
    }
    
    /// Static error logging method
    public static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.error(message, file: file, function: function, line: line)
    }
    
    /// Static verbose logging method (mapped to trace)
    public static func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.trace(message, file: file, function: function, line: line)
    }
    
    /// Static server logging method (mapped to info with SERVER category)
    public static func server(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.info(message, category: "SERVER", file: file, function: function, line: line)
    }
}
