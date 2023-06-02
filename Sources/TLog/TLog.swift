// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class TLog {
    static var dateFormat = "hh:mm:ss"
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    public static var isLoggingEnabled: Bool = true
    
    private static let currentDate = Date().toString()
}

// MARK: - Public Functions
extension TLog {
    public class func error(
        _ object: Any,
        filename: String = #file,
        line: Int = #line
    ) {
        print(
            "\(currentDate) \(TLogEvent.error.rawValue)[\(sourceFileName(filePath: filename))]:line \(line) -> \(object)",
            isLoggingEnabled: isLoggingEnabled
        )
    }
    
    public class func info(
        _ object: Any,
        filename: String = #file,
        line: Int = #line
    ) {
        print(
            "\(currentDate) \(TLogEvent.info.rawValue)[\(sourceFileName(filePath: filename))]:line \(line) -> \(object)",
            isLoggingEnabled: isLoggingEnabled
        )
    }
    
    public class func debug(
        _ object: Any,
        filename: String = #file,
        line: Int = #line
    ) {
        print(
            "\(currentDate) \(TLogEvent.debug.rawValue)[\(sourceFileName(filePath: filename))]:line \(line) -> \(object)",
            isLoggingEnabled: isLoggingEnabled
        )
    }
    
    public class func verbose(
        _ object: Any,
        filename: String = #file,
        line: Int = #line
    ) {
        print(
            "\(currentDate) \(TLogEvent.verbose.rawValue)[\(sourceFileName(filePath: filename))]:line \(line) -> \(object)",
            isLoggingEnabled: isLoggingEnabled
        )
    }
    
    public class func warning(
        _ object: Any,
        filename: String = #file,
        line: Int = #line
    ) {
        print(
            "\(currentDate) \(TLogEvent.warning.rawValue)[\(sourceFileName(filePath: filename))]:line \(line) -> \(object)",
            isLoggingEnabled: isLoggingEnabled
        )
    }
    
    public class func server(
        _ object: Any,
        filename: String = #file,
        line: Int = #line
    ) {
        print(
            "\(currentDate) \(TLogEvent.server.rawValue)[\(sourceFileName(filePath: filename))]:line \(line) -> \(object)",
            isLoggingEnabled: isLoggingEnabled
        )
    }
}

// MARK: - Private Functions
extension TLog {
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}
