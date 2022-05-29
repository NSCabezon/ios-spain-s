import CoreFoundationLib

public protocol OperativeTrackerCapable {
    var trackerManager: TrackerManager { get }
    var extraParametersForTracker: [String: String] { get }
    
    func trackScreen(screenId: String?)
    func trackErrorEvent(page: String?, error: String?, code: String?)
}

public protocol OperativeSignatureTrackerCapable {
    var screenIdSignature: String { get }
}

public protocol OperativeOTPTrackerCapable {
    var screenIdOtp: String { get }
}

public extension OperativeTrackerCapable {
    func trackScreen(screenId: String?) {
        guard let page = screenId else { return }
        let paramaters: [String: String] = extraParametersForTracker
        trackerManager.trackScreen(screenId: page, extraParameters: paramaters)
    }
    
    func trackErrorEvent(page: String?, error: String?, code: String?) {
        guard let page = page else { return }
        var paramaters: [String: String] = extraParametersForTracker
        if let errorDesc = error {
            paramaters[TrackerDimension.descError.key] = errorDesc
        }
        if let errorCode = code {
            paramaters[TrackerDimension.codError.key] = errorCode
        }
        
        trackerManager.trackEvent(screenId: page, eventId: TrackerDimension.codError.key, extraParameters: paramaters)
    }
}
