import CoreFoundationLib

struct MockTrackerManager: TrackerManager {
    func trackScreen(screenId: String, extraParameters: [String : String]) { }
    
    func trackEvent(screenId: String, eventId: String, extraParameters: [String : String]) { }
    
    func trackEmma(token: String) { }
}
