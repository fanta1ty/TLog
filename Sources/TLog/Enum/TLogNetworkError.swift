import Foundation

enum TLogNetworkError: Error {
    case dataPreparationFailed
    case httpError(statusCode: Int, data: Data?)
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .dataPreparationFailed:
            return "Failed to prepare request data"
        case .httpError(let statusCode, _):
            return "HTTP error with status code: \(statusCode)"
        case .invalidResponse:
            return "Invalid response received"
        }
    }
}
