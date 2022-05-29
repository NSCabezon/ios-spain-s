import CoreFoundationLib

final class MockTrackerManager: TrackerManager {
    public init() {}
    public func trackScreen(screenId: String, extraParameters: [String: String]) {}
    public func trackEvent(screenId: String, eventId: String, extraParameters: [String: String]) {}
    public func trackEmma(token: String) {}
}
