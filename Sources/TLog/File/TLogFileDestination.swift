import Foundation

/// File output destination with rotation support
public class TLogFileDestination: TLogDestination {
    public var isEnabled: Bool = true
    public var minimumLevel: TLogLevel = .trace
    public var filters: [TLogFilter] = []
    public var formatter: TLogFormatter?
    
    public var maxFileSize: UInt64 = 10 * 1024 * 1024 // 10MB
    public var maxFiles: Int = 5
    public var compressionEnabled: Bool = true
    public var encryptionEnabled: Bool = false
    
    private let fileURL: URL
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private let queue = DispatchQueue(label: "com.tlog.file", qos: .utility)
    private let fileManager = FileManager.default
    
    public init(fileName: String = "app.log") {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logsDirectory = documentsPath.appendingPathComponent("Logs")
        
        // Create logs directory if it doesn't exist
        try? FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        
        self.fileURL = logsDirectory.appendingPathComponent(fileName)
    }
    
    public func write(_ message: TLogMessage) {
        guard isEnabled && message.level >= minimumLevel else { return }
        guard filters.allSatisfy({ $0.shouldLog(message) }) else { return }
        
        queue.async { [weak self] in
            self?.writeToFile(message)
        }
    }
    
    private func writeToFile(_ message: TLogMessage) {
        let formattedMessage = formatter?.format(message) ?? defaultFormat(message)
        let logLine = "\(formattedMessage)\n"
        
        guard let data = logLine.data(using: .utf8) else { return }
        
        // Rotate file if necessary
        rotateFileIfNeeded()
        
        // Write to file
        if fileManager.fileExists(atPath: fileURL.path) {
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try? data.write(to: fileURL)
        }
    }
    
    private func defaultFormat(_ message: TLogMessage) -> String {
        let timestamp = dateFormatter.string(from: message.timestamp)
        let threadName = message.threadInfo.isMainThread ? "main" : "bg(\(message.threadInfo.number))"
        return "\(timestamp) [\(message.level.description)] [\(message.category)] [\(threadName)] <\(message.file):\(message.line)> \(message.formattedMessage)"
    }
    
    private func rotateFileIfNeeded() {
        guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
              let fileSize = attributes[.size] as? UInt64,
              fileSize > maxFileSize else { return }
        
        let fileName = fileURL.deletingPathExtension().lastPathComponent
        let fileExtension = fileURL.pathExtension
        let directory = fileURL.deletingLastPathComponent()
        
        // Move existing rotated files
        for i in (1..<maxFiles).reversed() {
            let oldFile = directory.appendingPathComponent("\(fileName).\(i).\(fileExtension)")
            let newFile = directory.appendingPathComponent("\(fileName).\(i + 1).\(fileExtension)")
            
            if fileManager.fileExists(atPath: oldFile.path) {
                try? fileManager.moveItem(at: oldFile, to: newFile)
            }
        }
        
        // Move current file to .1
        let rotatedFile = directory.appendingPathComponent("\(fileName).1.\(fileExtension)")
        try? fileManager.moveItem(at: fileURL, to: rotatedFile)
        
        // Compress old file if enabled
        if compressionEnabled {
            compressFile(rotatedFile)
        }
        
        // Remove oldest file if necessary
        let oldestFile = directory.appendingPathComponent("\(fileName).\(maxFiles).\(fileExtension)")
        try? fileManager.removeItem(at: oldestFile)
    }
    
    private func compressFile(_ fileURL: URL) {
        // Basic compression implementation would go here
        // For production, consider using Compression framework
    }
    
    /// Get all log files including rotated ones
    public func getAllLogFiles() -> [URL] {
        let directory = fileURL.deletingLastPathComponent()
        let fileName = fileURL.deletingPathExtension().lastPathComponent
        let fileExtension = fileURL.pathExtension
        
        var files: [URL] = []
        
        // Add current file
        if fileManager.fileExists(atPath: fileURL.path) {
            files.append(fileURL)
        }
        
        // Add rotated files
        for i in 1...maxFiles {
            let rotatedFile = directory.appendingPathComponent("\(fileName).\(i).\(fileExtension)")
            if fileManager.fileExists(atPath: rotatedFile.path) {
                files.append(rotatedFile)
            }
        }
        
        return files
    }
    
    /// Export all logs as a single string
    public func exportLogs() -> String {
        let allFiles = getAllLogFiles()
        var content = ""
        
        for fileURL in allFiles {
            if let fileContent = try? String(contentsOf: fileURL) {
                content += "=== \(fileURL.lastPathComponent) ===\n"
                content += fileContent
                content += "\n\n"
            }
        }
        
        return content
    }
}
