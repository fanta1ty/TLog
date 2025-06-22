/// Protocol for filtering log messages
public protocol TLogFilter {
    func shouldLog(_ message: TLogMessage) -> Bool
}
