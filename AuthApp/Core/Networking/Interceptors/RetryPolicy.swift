//
//  RetryPolicy.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//
// Decides whether a failed request is worth retrying, and how long to wait.
// Only transport failures qualify — retrying a 401 or a bad JSON body just
// stalls the user for no benefit, since the server would say the same thing again.
 
/// Decides whether a failed request should be retried, and after how long.
struct RetryPolicy: Sendable {
    private let maxAttempts: Int
    private let baseDelayMilliseconds: Int
    private let isRetryable: @Sendable (NetworkError) -> Bool

    init(
        maxAttempts: Int,
        baseDelayMilliseconds: Int,
        isRetryable: @escaping @Sendable (NetworkError) -> Bool
    ) {
        self.maxAttempts = maxAttempts
        self.baseDelayMilliseconds = baseDelayMilliseconds
        self.isRetryable = isRetryable
    }
 
    /// Only transient transport failures are retried — HTTP errors
    /// and decoding failures are not, since retrying a 401 or a malformed-body
    /// 200 wastes time and produces a misleading "still loading" experience
    /// for what is actually a deterministic failure.
    static let `default` = RetryPolicy(maxAttempts: 3, baseDelayMilliseconds: 300) { error in
        if case .transport = error { return true }
        return false
    }
 
    /// Never retries. Used in unit tests so failures surface immediately and
    /// deterministically, without `Task.sleep` slowing the suite down.
    static let noRetry = RetryPolicy(maxAttempts: 1, baseDelayMilliseconds: 0) { _ in false }

    func shouldRetry(_ error: NetworkError, attempt: Int) -> Bool {
        attempt < maxAttempts && isRetryable(error)
    }
 
    /// Exponential backoff: baseDelay * 2^(attempt - 1).
    func delay(forAttempt attempt: Int) -> Duration {
        let multiplier = 1 << max(0, attempt - 1)
        return .milliseconds(baseDelayMilliseconds * multiplier)
    }
}
