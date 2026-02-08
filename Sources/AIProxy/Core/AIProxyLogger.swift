import Foundation

nonisolated public enum AIProxyLogLevel: Int, Sendable {
    case debug
    case info
    case warning
    case error
    case critical

    func isAtOrAboveThresholdLevel(_ threshold: AIProxyLogLevel) -> Bool {
        return self.rawValue >= threshold.rawValue
    }

    /// This must only be accessed through `ProtectedPropertyQueue.callerDesiredLogLevel`.
    nonisolated(unsafe) static var _callerDesiredLogLevel = AIProxyLogLevel.warning
    nonisolated static var callerDesiredLogLevel: AIProxyLogLevel {
        get {
            ProtectedPropertyQueue.callerDesiredLogLevel.sync { self._callerDesiredLogLevel }
        }
        set {
            ProtectedPropertyQueue.callerDesiredLogLevel.async(flags: .barrier) { self._callerDesiredLogLevel = newValue }
        }
    }
}

/// Cross-platform logger that works on macOS, iOS, Linux, etc.
nonisolated internal struct Logger {
    let subsystem: String
    let category: String

    init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }

    nonisolated func debug(_ message: String) {
        log(level: .debug, message: message)
    }

    nonisolated func info(_ message: String) {
        log(level: .info, message: message)
    }

    nonisolated func warning(_ message: String) {
        log(level: .warning, message: message)
    }

    nonisolated func error(_ message: String) {
        log(level: .error, message: message)
    }

    nonisolated func critical(_ message: String) {
        log(level: .critical, message: message)
    }

    private nonisolated func log(level: AIProxyLogLevel, message: String) {
        guard level.isAtOrAboveThresholdLevel(AIProxyLogLevel.callerDesiredLogLevel) else {
            return
        }
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let levelString = "\(level)".uppercased()
        print("[\(timestamp)] [\(levelString)] [\(subsystem)/\(category)] \(message)")
    }
}

nonisolated internal let aiproxyLogger = Logger(
    subsystem: {
        #if os(Linux)
        return "LinuxApp"
        #else
        return Bundle.main.bundleIdentifier ?? "UnknownApp"
        #endif
    }(),
    category: "AIProxy"
)

// Why not create a wrapper instead of forcing log callsites to include an `logIf(<level>)` check?
// Because we want to keep the same API as the original OSLog-based implementation.
// The `logIf` function returns nil if the log level is below threshold, allowing for optional chaining.
@inline(__always)
nonisolated internal func logIf(_ logLevel: AIProxyLogLevel) -> Logger? {
    return logLevel.isAtOrAboveThresholdLevel(AIProxyLogLevel.callerDesiredLogLevel) ? aiproxyLogger : nil
}
