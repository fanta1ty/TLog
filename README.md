![Logo](https://github.com/fanta1ty/TLog/blob/master/Logo/Logo.png)

# TLog 2.0 - Enhanced Swift Logging Library
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-brightgreen)](https://developer.apple.com/swift/)
[![Version](https://img.shields.io/cocoapods/v/TLog.svg?style=flat)](https://cocoapods.org/pods/TLog)
[![License](https://img.shields.io/cocoapods/l/TLog.svg?style=flat)](https://cocoapods.org/pods/TLog)
[![Platform](https://img.shields.io/cocoapods/p/TLog.svg?style=flat)](https://cocoapods.org/pods/TLog)
[![Email](https://img.shields.io/badge/contact-@thinhnguyen12389@gmail.com-blue)](thinhnguyen12389@gmail.com)

TLog is a powerful, lightweight, and easy-to-use logging library for Swift applications. It provides multiple output destinations, customizable formatting, and enterprise-grade features while maintaining simplicity and performance.

## 🚀 Features

### Core Features
- ✅ **Multiple Log Levels**: trace, debug, info, warning, error, critical
- ✅ **Multiple Destinations**: Console, File, OSLog, Network, Memory
- ✅ **Thread-Safe**: All operations are performed on dedicated queues
- ✅ **File Rotation**: Automatic log file rotation with size limits
- ✅ **Customizable Formatting**: Configure timestamp, emoji, category display
- ✅ **Zero Dependencies**: Pure Swift implementation
- ✅ **Backward Compatible**: Drop-in replacement for TLog 1.x

### Advanced Features
- 🔄 **Log Rotation**: Automatic file rotation with configurable size and count limits
- 📱 **OSLog Integration**: Native iOS logging system integration
- 🎨 **Emoji Support**: Visual log level indicators
- 📂 **Category System**: Organize logs by functional areas
- 🎯 **Filtering**: Per-destination log level filtering
- 🧵 **Thread Safety**: Concurrent logging without blocking
- 🔒 **Privacy Protection**: Built-in sensitive data redaction
- 📊 **Analytics**: Real-time log statistics and monitoring
- 🛡️ **Circuit Breaker**: Network destination protection
- ⚡ **Async Support**: Modern Swift concurrency integration


## 📦 Installation
### Swift Package Manager (Recommended)

#### **Method 1: Xcode Integration**
1. Open your project in Xcode
2. Go to **File → Add Package Dependencies**
3. Enter the repository URL:
   ```
   https://github.com/fanta1ty/TLog.git
   ```
4. Choose version `2.0.0` or **"Up to Next Major Version"**
5. Click **Add Package**

#### **Method 2: Package.swift**
Add TLog to your `Package.swift` dependencies:

```swift
// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/fanta1ty/TLog.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: ["TLog"]
        ),
    ]
)
```

Then run:
```bash
swift package update
```

### CocoaPods

#### **Add to Podfile**
```ruby
# Podfile
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  pod 'TLog', '~> 2.0'
end
```

#### **Install**
```bash
# Install CocoaPods (if not already installed)
sudo gem install cocoapods

# Install TLog
pod install

# Open workspace (not .xcodeproj)
open YourApp.xcworkspace
```

#### **Import in Swift**
```swift
import TLog
```

### Carthage

Add to your `Cartfile`:
```
github "fanta1ty/TLog" ~> 2.0
```

Then run:
```bash
carthage update --platform iOS
```

### Manual Installation

1. Download the source code from [GitHub releases](https://github.com/fanta1ty/TLog/releases)
2. Copy the `Sources/TLog` directory into your project
3. Add the files to your Xcode project

---

## 🔧 Quick Start

### Basic Usage (Backward Compatible)

```swift
import TLog

// Simple logging (same as TLog 1.x)
TLog.debug("Debug message")
TLog.info("Info message")
TLog.warning("Warning message")
TLog.error("Error message")

// Enable/disable logging
TLog.isLoggingEnabled = true
```

### Advanced Usage

```swift
import TLog

// Get the shared logger instance
let logger = TLog.shared

// Configure global settings
logger.minimumLevel = .info
logger.defaultCategory = "MyApp"

// Enable file logging
logger.enableFileLogging(fileName: "myapp.log")

// Log with categories
logger.info("User logged in", category: "AUTH")
logger.error("Database connection failed", category: "DATABASE")
logger.debug("API response received", category: "NETWORK")
```

---

## 📊 Log Levels

TLog supports six log levels in hierarchical order:

| Level | Description | Use Case | Production |
|-------|-------------|----------|------------|
| **trace** 🔍 | Finest level of detail | Method entry/exit, detailed flow | ❌ |
| **debug** 🐛 | Debugging information | Variable values, state changes | ❌ |
| **info** ℹ️ | General information | Application lifecycle, major events | ✅ |
| **warning** ⚠️ | Potentially harmful situations | Deprecated API usage, fallback scenarios | ✅ |
| **error** ❌ | Error events | Handled exceptions, failed operations | ✅ |
| **critical** 🔥 | Very severe errors | System failures, data corruption | ✅ |

### Usage Examples

```swift
// Method tracing (development only)
logger.trace("→ processUserData")
logger.trace("← processUserData completed")

// Debug information
logger.debug("API Response", metadata: [
    "status_code": .stringConvertible(200),
    "response_time": .stringConvertible(1.2)
])

// Important events
logger.info("User login successful", metadata: [
    "user_id": .string("12345"),
    "login_method": .string("oauth")
])

// Potential issues
logger.warning("API response time high", metadata: [
    "response_time": .stringConvertible(5.2),
    "threshold": .stringConvertible(3.0)
])

// Handled errors
logger.error("Payment processing failed", metadata: [
    "error_code": .string("CARD_DECLINED"),
    "amount": .stringConvertible(99.99)
])

// Critical system issues
logger.critical("Database connection lost", metadata: [
    "connection_attempts": .stringConvertible(3),
    "last_error": .string("Connection timeout")
])
```

---

## 🎯 Destinations

### Console Destination
Outputs formatted logs to the console with emoji and color support.

```swift
// Configure console formatting
logger.configureConsole(
    showEmojis: true,
    showTimestamp: true,
    showCategory: true,
    showLocation: true,
    showThreadInfo: true,
    colorOutput: true
)
```

**Output Example:**
```
14:32:18.742 ℹ️ [INFO] [AUTH] [main] <LoginViewController.swift:45> User authentication successful
```

### File Destination
Writes logs to files with automatic rotation.

```swift
// Enable file logging with custom settings
logger.enableFileLogging(fileName: "app.log")

// Or configure manually
let fileDestination = FileDestination(fileName: "custom.log")
fileDestination.maxFileSize = 5 * 1024 * 1024 // 5MB
fileDestination.maxFiles = 10
fileDestination.compressionEnabled = true
logger.addDestination(fileDestination)
```

**Features:**
- Automatic file rotation when size limit is reached
- Configurable number of archived files
- Thread-safe file operations
- Logs stored in app's Documents/Logs directory
- Optional compression for archived files

### Network Destination
Sends logs to remote servers with advanced features.

```swift
// Basic network logging
logger.enableNetworkLogging(
    endpoint: URL(string: "https://logs.myapp.com/api")!,
    authToken: "your-auth-token",
    minimumLevel: .error
)

// Advanced configuration
let networkConfig = NetworkConfiguration(
    endpoint: URL(string: "https://logs.myapp.com/api")!,
    httpMethod: .POST,
    format: .json,
    batchSize: 20,
    flushInterval: 30.0,
    authToken: "bearer-token",
    customHeaders: ["X-App-Version": "1.0.0"],
    enableGzip: true,
    retryPolicy: RetryPolicy(maxRetries: 3, baseDelay: 1.0)
)

let networkDestination = NetworkDestination(
    configuration: networkConfig,
    enableCircuitBreaker: true
)
logger.addDestination(networkDestination)
```

**Features:**
- Multiple HTTP methods (GET, POST, PUT, PATCH, DELETE)
- Various formats (JSON, JSON Lines, Plain Text, Custom)
- Batching and automatic flushing
- Authentication support
- Custom headers
- Gzip compression
- Circuit breaker protection
- Retry logic with exponential backoff

### Memory Destination
Stores logs in memory for testing and debugging.

```swift
// Enable memory logging
logger.enableMemoryLogging(maxMessages: 1000)

// Access stored messages
let memoryDest = logger.getMemoryDestination()
let allMessages = memoryDest?.getAllMessages()
let errorMessages = memoryDest?.getMessages(for: .error)
let networkLogs = memoryDest?.getMessages(for: "NETWORK")
```

### OSLog Destination (iOS 10+)
Integrates with Apple's unified logging system.

```swift
if #available(iOS 10.0, *) {
    let osLogDestination = OSLogDestination(
        subsystem: "com.myapp.logger",
        category: "network"
    )
    logger.addDestination(osLogDestination)
}
```

---

## 🛠 Custom Destinations

Create custom destinations by implementing the `LogDestination` protocol:

```swift
class SlackDestination: LogDestination {
    var isEnabled: Bool = true
    var minimumLevel: LogLevel = .error
    var filters: [LogFilter] = []
    var formatter: LogFormatter?
    
    private let webhookURL: URL
    
    init(webhookURL: URL) {
        self.webhookURL = webhookURL
    }
    
    func write(_ message: LogMessage) {
        guard isEnabled && message.level >= minimumLevel else { return }
        guard filters.allSatisfy({ $0.shouldLog(message) }) else { return }
        
        let slackMessage = [
            "text": formatter?.format(message) ?? message.formattedMessage,
            "channel": "#alerts",
            "username": "TLog Bot"
        ]
        
        // Send to Slack webhook
        sendToSlack(slackMessage)
    }
    
    private func sendToSlack(_ message: [String: Any]) {
        // Implementation for sending to Slack
    }
}

// Add custom destination
logger.addDestination(SlackDestination(webhookURL: slackWebhookURL))
```

---

## ⚙️ Configuration

### Environment-Based Setup

```swift
private func setupLogging() {
    let logger = TLog.shared
    
    #if DEBUG
    // 🛠️ Development Environment
    logger.configure(for: .development)
    logger.enableMemoryLogging(maxMessages: 1000)
    logger.configureConsole(
        showEmojis: true,
        showTimestamp: true,
        showThreadInfo: true,
        colorOutput: true
    )
    
    #elseif STAGING
    // 🧪 Staging Environment
    logger.configure(for: .staging)
    logger.enableFileLogging(fileName: "staging.log")
    logger.enableNetworkLogging(
        endpoint: URL(string: "https://staging-logs.myapp.com/api")!,
        authToken: "staging-auth-token",
        minimumLevel: .info
    )
    
    #else
    // 🏭 Production Environment
    logger.configure(for: .production)
    logger.enablePrivacyProtection() // 🔒 Protect user data
    logger.enableFileLogging(fileName: "production.log")
    logger.enableHealthMonitoring() // 🩺 Monitor logging health
    
    // Send critical errors to monitoring service
    logger.enableRobustNetworkLogging(
        endpoint: URL(string: "https://logs.myapp.com/api/errors")!,
        authToken: "prod-auth-token",
        minimumLevel: .error,
        enableCircuitBreaker: true
    )
    #endif
    
    // 🌍 Global metadata for all logs
    logger.globalMetadata = [
        "app_version": .string(Bundle.main.appVersion),
        "user_id": .string(currentUserID),
        "session_id": .string(UUID().uuidString)
    ]
}
```

### Filtering and Privacy

```swift
// Add filters
logger.addGlobalFilter(LogFilters.category(["NETWORK", "DATABASE"]))
logger.addGlobalFilter(LogFilters.rateLimit(maxMessages: 100, per: 60.0))
logger.addGlobalFilter(LogFilters.contains("ERROR"))

// Enable privacy protection
var privacySettings = PrivacySettings()
privacySettings.enableDataRedaction = true
privacySettings.enableEmailRedaction = true
privacySettings.enableIPRedaction = true
logger.enablePrivacyProtection(settings: privacySettings)
```

---

## 📱 Platform Support

| Platform | Minimum Version | Notes |
|----------|----------------|-------|
| iOS | 12.0+ | Full feature support |
| macOS | 10.14+ | Full feature support |
| tvOS | 12.0+ | Console and file logging |
| watchOS | 5.0+ | Console logging only |

---

## 🔒 Thread Safety

TLog is fully thread-safe:
- All logging operations use dedicated concurrent queues
- File operations are serialized to prevent corruption
- No blocking of the main thread
- Safe to use from any thread or queue

```swift
// Safe to call from any thread
DispatchQueue.global().async {
    TLog.info("Background thread log")
}

DispatchQueue.main.async {
    TLog.info("Main thread log")
}
```

---

## 📈 Performance

TLog is designed for high performance:
- Minimal overhead for disabled log levels
- Asynchronous writing to destinations
- Efficient string formatting
- Memory-conscious design

**Benchmarks** (iPhone 12 Pro, Release build):
- 1M debug logs (disabled): ~0.1 seconds
- 100K info logs (enabled): ~2.3 seconds
- File logging overhead: ~5% additional time

```swift
// Enable performance monitoring
logger.isPerformanceMonitoringEnabled = true

// Check performance metrics
let metrics = logger.performanceMetrics
print("Average log time: \(metrics.averageLogTime * 1000)ms")
print("Messages by level: \(metrics.messagesByLevel)")
```

---

## 🔄 Migration from TLog 1.x

TLog 2.0 is backward compatible with 1.x. Existing code works without changes:

```swift
// TLog 1.x code works as-is
TLog.debug("Debug message")
TLog.info("Info message")
TLog.error("Error message")
TLog.isLoggingEnabled = false

// But you can now use enhanced features
TLog.shared.enableFileLogging()
TLog.shared.minimumLevel = .warning
```

### Migration Checklist

- ✅ Replace `TLog.verbose()` with `TLog.trace()` for semantic clarity
- ✅ Replace `TLog.server()` with `TLog.info(category: "SERVER")`
- ✅ Consider using metadata instead of string interpolation
- ✅ Set up environment-based configuration
- ✅ Enable privacy protection for production

---

## 📖 API Reference

### Core Methods

```swift
// Instance methods with metadata support
func trace(_ message: String, metadata: LogMetadata = [:], category: String? = nil)
func debug(_ message: String, metadata: LogMetadata = [:], category: String? = nil)
func info(_ message: String, metadata: LogMetadata = [:], category: String? = nil)
func warning(_ message: String, metadata: LogMetadata = [:], category: String? = nil)
func error(_ message: String, metadata: LogMetadata = [:], category: String? = nil)
func critical(_ message: String, metadata: LogMetadata = [:], category: String? = nil)

// Static methods (backward compatibility)
static func debug(_ message: String)
static func info(_ message: String)
static func warning(_ message: String)
static func error(_ message: String)
static func verbose(_ message: String) // Maps to trace
static func server(_ message: String)  // Maps to info with "SERVER" category

// Async methods (iOS 13+)
func traceAsync(_ message: String, metadata: LogMetadata = [:], category: String? = nil) async
func debugAsync(_ message: String, metadata: LogMetadata = [:], category: String? = nil) async
// ... other async methods

// Convenience methods
func error(_ error: Error, message: String = "Error occurred", category: String? = nil)
func time<T>(_ operation: String, category: String? = nil, block: () throws -> T) rethrows -> T
func timeAsync<T>(_ operation: String, category: String? = nil, block: () async throws -> T) async rethrows -> T
```

### Configuration Methods

```swift
func configure(for environment: Environment)
func configure(with configuration: TLogConfiguration)
func addDestination(_ destination: LogDestination)
func removeAllDestinations()
func enableFileLogging(fileName: String = "app.log")
func enableNetworkLogging(endpoint: URL, authToken: String? = nil, minimumLevel: LogLevel = .error)
func enableMemoryLogging(maxMessages: Int = 1000)
func enablePrivacyProtection(settings: PrivacySettings = PrivacySettings())
func enableHealthMonitoring()
func configureConsole(showEmojis: Bool, showTimestamp: Bool, ...)
```

---

## 🧪 Testing

```swift
import XCTest
@testable import MyApp
import TLog

class MyAppTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        // Configure TLog for testing
        TLog.shared.configureForTesting()
    }
    
    override func tearDown() {
        // Clear logs after each test
        TLog.shared.getMemoryDestination()?.clear()
        super.tearDown()
    }
    
    func testUserLogin() {
        // Your test code
        performUserLogin()
        
        // Verify logging
        let memoryDest = TLog.shared.getMemoryDestination()!
        let logs = memoryDest.getAllMessages()
        
        XCTAssertTrue(logs.contains { $0.message.contains("User login") })
        XCTAssertEqual(memoryDest.getMessages(for: "AUTH").count, 2)
    }
}
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone repository
git clone https://github.com/fanta1ty/TLog.git
cd TLog

# Open in Xcode
open Package.swift

# Or build with Swift Package Manager
swift build
swift test
```

### Contribution Process

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`swift test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

---

## 📄 License

TLog is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

---

## 🙏 Acknowledgments

- Original TLog library concept
- Swift community for logging best practices
- Apple's OSLog for system integration patterns
- Contributors and beta testers

---

## 📞 Support

- 📧 **Email**: thinhnguyen12389@gmail.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/fanta1ty/TLog/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/fanta1ty/TLog/discussions)
- 📖 **Documentation**: [API Reference](https://fanta1ty.github.io/TLog/)
- 🔄 **Changelog**: [CHANGELOG.md](CHANGELOG.md)

---

## 🎯 Roadmap

### v2.1 (Coming Soon)
- [ ] SwiftUI log viewer component
- [ ] Structured logging improvements
- [ ] More built-in formatters
- [ ] Enhanced privacy controls

### v2.2 (Future)
- [ ] macOS app for log analysis
- [ ] Cloud logging service integration
- [ ] Machine learning log analysis
- [ ] Advanced filtering DSL

---

Made with ❤️ by [fanta1ty](https://github.com/fanta1ty)

## 🔧 Quick Start

### Basic Usage (Backward Compatible)

```swift
import TLog

// Simple logging (same as TLog 1.x)
TLog.debug("Debug message")
TLog.info("Info message")
TLog.warning("Warning message")
TLog.error("Error message")

// Enable/disable logging
TLog.isLoggingEnabled = true
```

### Advanced Usage

```swift
import TLog

// Get the shared logger instance
let logger = TLog.shared

// Configure global settings
logger.minimumLevel = .info
logger.defaultCategory = "MyApp"

// Enable file logging
logger.enableFileLogging(fileName: "myapp.log")

// Log with categories
logger.info("User logged in", category: "AUTH")
logger.error("Database connection failed", category: "DATABASE")
logger.debug("API response received", category: "NETWORK")
```

## 📊 Log Levels

TLog supports six log levels in hierarchical order:

| Level | Description | Use Case |
|-------|-------------|----------|
| **trace** 🔍 | Finest level of detail | Method entry/exit, detailed flow |
| **debug** 🐛 | Debugging information | Variable values, state changes |
| **info** ℹ️ | General information | Application lifecycle, major events |
| **warning** ⚠️ | Potentially harmful situations | Deprecated API usage, fallback scenarios |
| **error** ❌ | Error events | Handled exceptions, failed operations |
| **critical** 🔥 | Very severe errors | System failures, data corruption |

## 🎯 Destinations

### Console Destination
Outputs formatted logs to the console with emoji and color support.

```swift
// Configure console formatting
logger.configureConsole(
    showEmojis: true,
    showTimestamp: true,
    showCategory: true,
    showLocation: true
)
```

**Output Example:**
```
14:32:18.742 ℹ️ [INFO] [AUTH] <LoginViewController.swift:45> User authentication successful
```

### File Destination
Writes logs to files with automatic rotation.

```swift
// Enable file logging with custom settings
let fileDestination = FileDestination(fileName: "app.log")
fileDestination.maxFileSize = 5 * 1024 * 1024 // 5MB
fileDestination.maxFiles = 10
logger.addDestination(fileDestination)
```

**Features:**
- Automatic file rotation when size limit is reached
- Configurable number of archived files
- Thread-safe file operations
- Logs stored in app's Documents/Logs directory

### OSLog Destination (iOS 10+)
Integrates with Apple's unified logging system.

```swift
if #available(iOS 10.0, *) {
    let osLogDestination = OSLogDestination(
        subsystem: "com.myapp.logger",
        category: "network"
    )
    logger.addDestination(osLogDestination)
}
```

## 🛠 Custom Destinations

Create custom destinations by implementing the `LogDestination` protocol:

```swift
class NetworkDestination: LogDestination {
    var isEnabled: Bool = true
    var minimumLevel: LogLevel = .error
    
    func write(_ message: LogMessage) {
        // Send logs to remote server
        sendToServer(message)
    }
    
    private func sendToServer(_ message: LogMessage) {
        // Implementation for sending logs to server
    }
}

// Add custom destination
logger.addDestination(NetworkDestination())
```

## ⚙️ Configuration

### Global Configuration

```swift
let logger = TLog.shared

// Set minimum log level
logger.minimumLevel = .warning

// Set default category
logger.defaultCategory = "MyApp"

// Enable/disable all logging
logger.isEnabled = true
```

### Per-Destination Configuration

```swift
// Configure specific destinations
for destination in logger.destinations {
    if let console = destination as? ConsoleDestination {
        console.minimumLevel = .debug
        console.showEmojis = false
    }
    
    if let file = destination as? FileDestination {
        file.minimumLevel = .info
        file.maxFileSize = 2 * 1024 * 1024 // 2MB
    }
}
```

## 📱 Platform Support

| Platform | Minimum Version | Notes |
|----------|----------------|-------|
| iOS | 12.0+ | Full feature support |
| macOS | 10.14+ | Full feature support |
| tvOS | 12.0+ | Console and file logging |
| watchOS | 5.0+ | Console logging only |

## 🔒 Thread Safety

TLog is fully thread-safe:
- All logging operations use dedicated concurrent queues
- File operations are serialized to prevent corruption
- No blocking of the main thread
- Safe to use from any thread or queue

## 📈 Performance

TLog is designed for high performance:
- Minimal overhead for disabled log levels
- Asynchronous writing to destinations
- Efficient string formatting
- Memory-conscious design

**Benchmarks** (iPhone 12 Pro, Release build):
- 1M debug logs (disabled): ~0.1 seconds
- 100K info logs (enabled): ~2.3 seconds
- File logging overhead: ~5% additional time

## 🔄 Migration from TLog 1.x

TLog 2.0 is backward compatible with 1.x. Existing code works without changes:

```swift
// TLog 1.x code works as-is
TLog.debug("Debug message")
TLog.info("Info message")
TLog.error("Error message")
TLog.isLoggingEnabled = false

// But you can now use enhanced features
TLog.shared.enableFileLogging()
TLog.shared.minimumLevel = .warning
```

## 📖 API Reference

### Core Methods

```swift
// Instance methods
func trace(_ message: String, category: String? = nil)
func debug(_ message: String, category: String? = nil)
func info(_ message: String, category: String? = nil)
func warning(_ message: String, category: String? = nil)
func error(_ message: String, category: String? = nil)
func critical(_ message: String, category: String? = nil)

// Static methods (backward compatibility)
static func debug(_ message: String)
static func info(_ message: String)
static func warning(_ message: String)
static func error(_ message: String)
static func verbose(_ message: String) // Maps to trace
static func server(_ message: String)  // Maps to info with "SERVER" category
```

### Configuration Methods

```swift
func addDestination(_ destination: LogDestination)
func removeAllDestinations()
func enableFileLogging(fileName: String = "app.log")
func configureConsole(showEmojis: Bool, showTimestamp: Bool, ...)
func getLogFileURL() -> URL?
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

TLog is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## 🙏 Acknowledgments

- Original TLog library concept
- Swift community for logging best practices
- Apple's OSLog for system integration patterns

## 📞 Support

- 📧 Email: thinhnguyen12389@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/fanta1ty/TLog/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/fanta1ty/TLog/discussions)

---
