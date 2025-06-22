import Foundation

/// HTTP methods supported for network logging
public enum TLogHTTPMethod: String, CaseIterable {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}
