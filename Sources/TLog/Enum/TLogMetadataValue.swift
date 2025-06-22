import Foundation

/// Key-value metadata that can be attached to log messages
public typealias TLogMetadata = [String: TLogMetadataValue]

/// Supported metadata value types
public enum TLogMetadataValue: CustomStringConvertible {
    case string(String)
    case stringConvertible(CustomStringConvertible)
    case dictionary(TLogMetadata)
    case array([TLogMetadataValue])
    
    public var description: String {
        switch self {
        case .string(let str):
            return str
            
        case .stringConvertible(let convertible):
            return convertible.description
            
        case .dictionary(let dict):
            return dict.mapValues { $0.description }.description
            
        case .array(let array):
            return array.map { $0.description }.description
        }
    }
}
