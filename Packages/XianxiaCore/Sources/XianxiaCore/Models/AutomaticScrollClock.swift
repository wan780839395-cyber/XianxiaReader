import Foundation

/// Elapsed-time movement, independent of UIKit, display frequency and storage.
public struct AutomaticScrollClock: Sendable {
    private var previous: TimeInterval?
    public init() {}
    public mutating func reset() { previous = nil }

    public mutating func distance(at timestamp: TimeInterval, viewportHeight: Double,
                                  screensPerMinute: Double) -> Double {
        guard timestamp.isFinite else { previous = nil; return 0 }
        defer { previous = timestamp }
        guard let previous, timestamp > previous, timestamp - previous <= 0.25,
              viewportHeight.isFinite, viewportHeight > 0,
              screensPerMinute.isFinite, (0.5...6).contains(screensPerMinute) else { return 0 }
        // CGFloat retains fractional points on Apple platforms; never round per frame.
        return (timestamp - previous) * viewportHeight * screensPerMinute / 60
    }
}
