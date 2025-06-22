/// Protocol for different log output destinations
public protocol TLogDestination {
    func write(_ message: TLogMessage)
    var isEnabled: Bool { get set }
    var minimumLevel: TLogLevel { get set }
    var filters: [TLogFilter] { get set }
    var formatter: TLogFormatter? { get set }
}
