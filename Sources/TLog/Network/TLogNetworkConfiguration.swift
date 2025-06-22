import Foundation

/// Network destination configuration
public struct TLogNetworkConfiguration {
    public let endpoint: URL
    public let httpMethod: TLogHTTPMethod
    public let format: TLogNetworkLogFormat
    public let batchSize: Int
    public let flushInterval: TimeInterval
    public let authToken: String?
    public let customHeaders: [String: String]
    public let timeout: TimeInterval
    public let enableGzip: Bool
    public let retryPolicy: TLogRetryPolicy
    
    public init(
        endpoint: URL,
        httpMethod: TLogHTTPMethod = .POST,
        format: TLogNetworkLogFormat = .json,
        batchSize: Int = 50,
        flushInterval: TimeInterval = 30.0,
        authToken: String? = nil,
        customHeaders: [String: String] = [:],
        timeout: TimeInterval = 30.0,
        enableGzip: Bool = false,
        retryPolicy: TLogRetryPolicy = TLogRetryPolicy()
    ) {
        self.endpoint = endpoint
        self.httpMethod = httpMethod
        self.format = format
        self.batchSize = batchSize
        self.flushInterval = flushInterval
        self.authToken = authToken
        self.customHeaders = customHeaders
        self.timeout = timeout
        self.enableGzip = enableGzip
        self.retryPolicy = retryPolicy
    }
}
