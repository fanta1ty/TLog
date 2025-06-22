/// Protocol for formatting log messages
public protocol TLogFormatter {
    func format(_ message: TLogMessage) -> String
}
