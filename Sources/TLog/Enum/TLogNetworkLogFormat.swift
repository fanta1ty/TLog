import Foundation

/// Network logging format options
public enum TLogNetworkLogFormat {
    case json
    case jsonLines
    case plainText
    case custom(formatter: (TLogMessage) -> Data?)
}
