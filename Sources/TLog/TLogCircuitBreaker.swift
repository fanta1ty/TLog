import Foundation

/// Circuit breaker to prevent network destination overload and cascading failures
public class TLogCircuitBreaker {
    public enum TLogState {
        case closed         // Normal operation - requests go through
        case open           // Failure mode - requests are blocked
        case halfOpen       // Testing mode - limited requests to test recovery
    }
    
    // MARK: - Error Types
    public enum TLogCircuitBreakerError: Error, LocalizedError {
        case circuitOpen
        case tooManyRequests
        case executionFailed(underlying: Error)
        
        public var errorDescription: String? {
            switch self {
            case .circuitOpen:
                return "Circuit breaker is open - requests are being blocked"
            case .tooManyRequests:
                return "Too many requests in half-open state"
            case .executionFailed(let error):
                return "Execution failed: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Configuration
    /// Configuration parameters for the circuit breaker
    public struct TLogConfiguration {
        public let failureThreshold: Int          // Number of failures before opening
        public let timeout: TimeInterval          // How long to stay open
        public let successThreshold: Int          // Successes needed to close from half-open
        public let halfOpenMaxRequests: Int       // Max concurrent requests in half-open
        
        public init(
            failureThreshold: Int = 5,
            timeout: TimeInterval = 60.0,
            successThreshold: Int = 3,
            halfOpenMaxRequests: Int = 1
        ) {
            self.failureThreshold = failureThreshold
            self.timeout = timeout
            self.successThreshold = successThreshold
            self.halfOpenMaxRequests = halfOpenMaxRequests
        }
    }
    
    // MARK: - Properties
    
    /// Current state of the circuit breaker
    public private(set) var state: TLogState = .closed
    
    /// Configuration settings
    private let configuration: TLogConfiguration
    
    /// Number of consecutive failures
    private var failureCount: Int = 0
    
    /// Number of consecutive successes (in half-open state)
    private var successCount: Int = 0
    
    /// Timestamp of the last failure
    private var lastFailureTime: Date?
    
    /// Number of requests currently being processed in half-open state
    private var halfOpenRequestCount: Int = 0
    
    /// Thread-safe access queue
    private let queue = DispatchQueue(label: "circuit.breaker", attributes: .concurrent)
    
    /// Statistics tracking
    public private(set) var statistics = TLogStatistics()
    
    // MARK: - Statistics
    
    /// Statistics about circuit breaker operations
    public struct TLogStatistics {
        public private(set) var totalRequests: Int = 0
        public private(set) var successfulRequests: Int = 0
        public private(set) var failedRequests: Int = 0
        public private(set) var rejectedRequests: Int = 0
        public private(set) var stateTransitions: Int = 0
        public private(set) var lastStateChange: Date = Date()
        
        public var successRate: Double {
            guard totalRequests > 0 else { return 0.0 }
            return Double(successfulRequests) / Double(totalRequests)
        }
        
        public var rejectionRate: Double {
            guard totalRequests > 0 else { return 0.0 }
            return Double(rejectedRequests) / Double(totalRequests)
        }
        
        fileprivate mutating func recordRequest() {
            totalRequests += 1
        }
        
        fileprivate mutating func recordSuccess() {
            successfulRequests += 1
        }
        
        fileprivate mutating func recordFailure() {
            failedRequests += 1
        }
        
        fileprivate mutating func recordRejection() {
            rejectedRequests += 1
        }
        
        fileprivate mutating func recordStateTransition() {
            stateTransitions += 1
            lastStateChange = Date()
        }
    }
    
    // MARK: - Initialization
    
    /// Initialize circuit breaker with configuration
    /// - Parameter configuration: Circuit breaker configuration
    public init(configuration: TLogConfiguration = TLogConfiguration()) {
        self.configuration = configuration
    }
    
    /// Convenience initializer with individual parameters
    /// - Parameters:
    ///   - failureThreshold: Number of failures before opening circuit
    ///   - timeout: Time to wait before transitioning from open to half-open
    ///   - successThreshold: Number of successes needed to close circuit from half-open
    ///   - halfOpenMaxRequests: Maximum concurrent requests in half-open state
    public convenience init(
        failureThreshold: Int = 5,
        timeout: TimeInterval = 60.0,
        successThreshold: Int = 3,
        halfOpenMaxRequests: Int = 1
    ) {
        let config = TLogConfiguration(
            failureThreshold: failureThreshold,
            timeout: timeout,
            successThreshold: successThreshold,
            halfOpenMaxRequests: halfOpenMaxRequests
        )
        self.init(configuration: config)
    }
    
    // MARK: - Public Methods
    
    /// Execute an operation through the circuit breaker
    /// - Parameter operation: The operation to execute
    /// - Returns: The result of the operation
    /// - Throws: CircuitBreakerError if circuit is open or operation fails
    public func execute<T>(_ operation: () throws -> T) throws -> T {
        return try queue.sync {
            // Record the request
            statistics.recordRequest()
            
            // Check current state and decide whether to allow the request
            try checkAndUpdateState()
            
            // Execute the operation
            do {
                let result = try operation()
                handleSuccess()
                statistics.recordSuccess()
                return result
            } catch {
                handleFailure()
                statistics.recordFailure()
                throw TLogCircuitBreakerError.executionFailed(underlying: error)
            }
        }
    }
    
    /// Execute an async operation through the circuit breaker
    /// - Parameter operation: The async operation to execute
    /// - Returns: The result of the operation
    /// - Throws: CircuitBreakerError if circuit is open or operation fails
    public func executeAsync<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        // Record the request
        await withCheckedContinuation { continuation in
            queue.async {
                self.statistics.recordRequest()
                continuation.resume()
            }
        }
        
        // Check current state and decide whether to allow the request
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    try self.checkAndUpdateState()
                    continuation.resume()
                } catch {
                    self.statistics.recordRejection()
                    continuation.resume(throwing: error)
                }
            }
        }
        
        // Execute the operation
        do {
            let result = try await operation()
            
            // Handle success
            await withCheckedContinuation { continuation in
                queue.async {
                    self.handleSuccess()
                    self.statistics.recordSuccess()
                    continuation.resume()
                }
            }
            
            return result
        } catch {
            // Handle failure
            await withCheckedContinuation { continuation in
                queue.async {
                    self.handleFailure()
                    self.statistics.recordFailure()
                    continuation.resume()
                }
            }
            
            throw TLogCircuitBreakerError.executionFailed(underlying: error)
        }
    }
    
    /// Check if the circuit breaker is currently allowing requests
    /// - Returns: true if requests are allowed, false otherwise
    public func isRequestAllowed() -> Bool {
        return queue.sync {
            switch state {
            case .closed:
                return true
            case .open:
                return shouldTransitionToHalfOpen()
            case .halfOpen:
                return halfOpenRequestCount < configuration.halfOpenMaxRequests
            }
        }
    }
    
    /// Reset the circuit breaker to closed state
    public func reset() {
        queue.async(flags: .barrier) {
            self.state = .closed
            self.failureCount = 0
            self.successCount = 0
            self.halfOpenRequestCount = 0
            self.lastFailureTime = nil
            self.statistics.recordStateTransition()
        }
    }
    
    /// Get current circuit breaker status
    /// - Returns: A snapshot of the current status
    public func getStatus() -> Status {
        return queue.sync {
            Status(
                state: state,
                failureCount: failureCount,
                successCount: successCount,
                lastFailureTime: lastFailureTime,
                statistics: statistics
            )
        }
    }
    
    // MARK: - Status Structure
    
    /// Current status of the circuit breaker
    public struct Status {
        public let state: TLogState
        public let failureCount: Int
        public let successCount: Int
        public let lastFailureTime: Date?
        public let statistics: TLogStatistics
        
        public var isHealthy: Bool {
            switch state {
            case .closed:
                return true
            case .open, .halfOpen:
                return false
            }
        }
        
        public var description: String {
            switch state {
            case .closed:
                return "Circuit is CLOSED - accepting requests"
            case .open:
                return "Circuit is OPEN - rejecting requests (failures: \(failureCount))"
            case .halfOpen:
                return "Circuit is HALF-OPEN - testing recovery (successes: \(successCount))"
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Check current state and update if necessary, then determine if request should be allowed
    private func checkAndUpdateState() throws {
        switch state {
        case .closed:
            // Normal operation - allow request
            break
            
        case .open:
            // Check if we should transition to half-open
            if shouldTransitionToHalfOpen() {
                transitionToHalfOpen()
            } else {
                statistics.recordRejection()
                throw TLogCircuitBreakerError.circuitOpen
            }
            
        case .halfOpen:
            // Check if we can accept more requests
            if halfOpenRequestCount >= configuration.halfOpenMaxRequests {
                statistics.recordRejection()
                throw TLogCircuitBreakerError.tooManyRequests
            } else {
                halfOpenRequestCount += 1
            }
        }
    }
    
    /// Handle successful operation
    private func handleSuccess() {
        switch state {
        case .closed:
            // Reset failure count on success
            failureCount = 0
            
        case .halfOpen:
            successCount += 1
            halfOpenRequestCount -= 1
            
            // Check if we should transition to closed
            if successCount >= configuration.successThreshold {
                transitionToClosed()
            }
            
        case .open:
            // This shouldn't happen, but handle gracefully
            break
        }
    }
    
    /// Handle failed operation
    private func handleFailure() {
        lastFailureTime = Date()
        
        switch state {
        case .closed:
            failureCount += 1
            
            // Check if we should transition to open
            if failureCount >= configuration.failureThreshold {
                transitionToOpen()
            }
            
        case .halfOpen:
            halfOpenRequestCount -= 1
            
            // Any failure in half-open immediately transitions to open
            transitionToOpen()
            
        case .open:
            // Already open, just record the failure
            failureCount += 1
        }
    }
    
    /// Check if circuit should transition from open to half-open
    private func shouldTransitionToHalfOpen() -> Bool {
        guard let lastFailure = lastFailureTime else { return false }
        return Date().timeIntervalSince(lastFailure) >= configuration.timeout
    }
    
    /// Transition to closed state
    private func transitionToClosed() {
        print("🟢 CircuitBreaker: Transitioning to CLOSED state")
        state = .closed
        failureCount = 0
        successCount = 0
        halfOpenRequestCount = 0
        statistics.recordStateTransition()
    }
    
    /// Transition to open state
    private func transitionToOpen() {
        print("🔴 CircuitBreaker: Transitioning to OPEN state (failures: \(failureCount))")
        state = .open
        successCount = 0
        halfOpenRequestCount = 0
        statistics.recordStateTransition()
    }
    
    /// Transition to half-open state
    private func transitionToHalfOpen() {
        print("🟡 CircuitBreaker: Transitioning to HALF-OPEN state")
        state = .halfOpen
        successCount = 0
        halfOpenRequestCount = 0
        statistics.recordStateTransition()
    }
}
