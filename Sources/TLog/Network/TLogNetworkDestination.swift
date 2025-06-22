import Foundation

/// Network destination for remote logging
public class NetworkDestination: TLogDestination {
    public var isEnabled: Bool = true
    public var minimumLevel: TLogLevel = .error
    public var filters: [TLogFilter] = []
    public var formatter: TLogFormatter?
    
    private let configuration: TLogNetworkConfiguration
    private var pendingMessages: [TLogMessage] = []
    private let queue = DispatchQueue(label: "com.tlog.network", qos: .utility)
    private var flushTimer: Timer?
    private let circuitBreaker: TLogCircuitBreaker?
    
    public init(
        configuration: TLogNetworkConfiguration, enableCircuitBreaker: Bool = true) {
        self.configuration = configuration
        self.circuitBreaker = enableCircuitBreaker ? TLogCircuitBreaker() : nil
        setupFlushTimer()
    }
    
    public convenience init(
        endpoint: URL,
        httpMethod: TLogHTTPMethod = .POST,
        batchSize: Int = 50,
        flushInterval: TimeInterval = 30.0,
        authToken: String? = nil
    ) {
        let config = TLogNetworkConfiguration(
            endpoint: endpoint,
            httpMethod: httpMethod,
            batchSize: batchSize,
            flushInterval: flushInterval,
            authToken: authToken
        )
        self.init(configuration: config)
    }
    
    deinit {
        flushTimer?.invalidate()
        flush() // Send any remaining messages
    }
    
    public func write(_ message: TLogMessage) {
        guard isEnabled && message.level >= minimumLevel else { return }
        guard filters.allSatisfy({ $0.shouldLog(message) }) else { return }
        
        queue.async { [weak self] in
            self?.addMessage(message)
        }
    }
}

// MARK: - Local Functions
extension NetworkDestination {
    private func setupFlushTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.flushTimer = Timer.scheduledTimer(withTimeInterval: self.configuration.flushInterval ?? 30.0, repeats: true) { _ in
                self.queue.async {
                    self.flush()
                }
            }
        }
    }
    
    private func flush() {
        guard !pendingMessages.isEmpty else { return }
        
        let messagesToSend = pendingMessages
        pendingMessages.removeAll()
        
        sendMessages(messagesToSend)
    }
    
    private func addMessage(_ message: TLogMessage) {
        pendingMessages.append(message)
        
        if pendingMessages.count >= configuration.batchSize {
            flush()
        }
    }
    
    private func sendMessages(_ messages: [TLogMessage]) {
        let sendOperation = { [weak self] in
            try self?.performNetworkRequest(with: messages)
        }
        
        if let circuitBreaker = circuitBreaker {
            do {
                try circuitBreaker.execute(sendOperation)
            } catch {
                handleNetworkError(error, messages: messages)
            }
        } else {
            do {
                try sendOperation()
            } catch {
                handleNetworkError(error, messages: messages)
            }
        }
    }
    
    private func performNetworkRequest(with messages: [TLogMessage]) throws {
        guard let requestData = prepareRequestData(messages) else {
            throw TLogNetworkError.dataPreparationFailed
        }
        
        var request = URLRequest(url: configuration.endpoint, timeoutInterval: configuration.timeout)
        request.httpMethod = configuration.httpMethod.rawValue
        
        // Set content type based on format
        switch configuration.format {
        case .json, .jsonLines:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .plainText:
            request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        case .custom:
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        }
        
        // Add authentication
        if let token = configuration.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add custom headers
        for (key, value) in configuration.customHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Handle compression
        if configuration.enableGzip {
            request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
            // Compress data here if needed
        }
        
        // Set request body based on HTTP method
        switch configuration.httpMethod {
        case .GET:
            // For GET requests, encode data as query parameters or skip body
            if let queryString = convertToQueryString(requestData) {
                var components = URLComponents(url: configuration.endpoint, resolvingAgainstBaseURL: false)
                components?.query = queryString
                if let newURL = components?.url {
                    request.url = newURL
                }
            }
        case .POST, .PUT, .PATCH:
            request.httpBody = requestData
        case .DELETE:
            // DELETE typically doesn't need body, but some APIs might accept it
            request.httpBody = requestData
        }
        
        // Perform the request with retry logic
        performRequestWithRetry(request, messages: messages, retryCount: 0)
    }
    
    private func performRequestWithRetry(_ request: URLRequest, messages: [TLogMessage], retryCount: Int) {
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleNetworkError(error, messages: messages, retryCount: retryCount, originalRequest: request)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if 200...299 ~= httpResponse.statusCode {
                    // Success - no action needed
                    return
                } else {
                    let error = TLogNetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
                    self.handleNetworkError(error, messages: messages, retryCount: retryCount, originalRequest: request)
                    return
                }
            }
        }.resume()
    }
    
    private func prepareRequestData(_ messages: [TLogMessage]) -> Data? {
        switch configuration.format {
        case .json:
            return prepareJSONData(messages)
        case .jsonLines:
            return prepareJSONLinesData(messages)
        case .plainText:
            return preparePlainTextData(messages)
        case .custom(let formatter):
            return prepareCustomData(messages, formatter: formatter)
        }
    }
    
    private func prepareJSONData(_ messages: [TLogMessage]) -> Data? {
        let jsonMessages = messages.map { message in
            return [
                "timestamp": ISO8601DateFormatter().string(from: message.timestamp),
                "level": message.level.description,
                "message": formatter?.format(message) ?? message.formattedMessage,
                "category": message.category,
                "file": message.file,
                "line": message.line,
                "function": message.function,
                "thread": [
                    "name": message.threadInfo.name ?? "",
                    "number": message.threadInfo.number,
                    "isMain": message.threadInfo.isMainThread
                ],
                "metadata": message.metadata.mapValues { $0.description }
            ]
        }
        
        return try? JSONSerialization.data(withJSONObject: jsonMessages)
    }
    
    private func prepareJSONLinesData(_ messages: [TLogMessage]) -> Data? {
        var result = Data()
        
        for message in messages {
            let jsonMessage = [
                "timestamp": ISO8601DateFormatter().string(from: message.timestamp),
                "level": message.level.description,
                "message": formatter?.format(message) ?? message.formattedMessage,
                "category": message.category,
                "file": message.file,
                "line": message.line,
                "metadata": message.metadata.mapValues { $0.description }
            ] as [String : Any]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonMessage),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                result.append((jsonString + "\n").data(using: .utf8) ?? Data())
            }
        }
        
        return result
    }
    
    private func preparePlainTextData(_ messages: [TLogMessage]) -> Data? {
        let textMessages = messages.map { message in
            formatter?.format(message) ?? message.formattedMessage
        }.joined(separator: "\n")
        
        return textMessages.data(using: .utf8)
    }
    
    private func prepareCustomData(_ messages: [TLogMessage], formatter: (TLogMessage) -> Data?) -> Data? {
        var result = Data()
        
        for message in messages {
            if let messageData = formatter(message) {
                result.append(messageData)
            }
        }
        
        return result.isEmpty ? nil : result
    }
    
    private func convertToQueryString(_ data: Data) -> String? {
        // Convert JSON data to query string for GET requests
        // This is a simplified implementation
        if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            let queryItems = jsonObject.enumerated().compactMap { index, item -> String? in
                let itemString = item.compactMap { key, value in
                    "\(key)=\(value)"
                }.joined(separator: "&")
                return "log[\(index)][\(itemString)]"
            }
            return queryItems.joined(separator: "&")
        }
        return nil
    }
    
    private func handleNetworkError(_ error: Error, messages: [TLogMessage], retryCount: Int = 0, originalRequest: URLRequest? = nil) {
        let shouldRetry = retryCount < configuration.retryPolicy.maxRetries
        
        if shouldRetry, let request = originalRequest {
            let delay = min(
                configuration.retryPolicy.baseDelay * pow(configuration.retryPolicy.backoffMultiplier, Double(retryCount)),
                configuration.retryPolicy.maxDelay
            )
            
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.performRequestWithRetry(request, messages: messages, retryCount: retryCount + 1)
            }
        } else {
            // All retries exhausted or no retry needed
            print("TLog Network Error (final): \(error)")
            
            // Optionally re-queue messages for later retry
            queue.async { [weak self] in
                self?.pendingMessages.insert(contentsOf: messages, at: 0)
            }
        }
    }
}
