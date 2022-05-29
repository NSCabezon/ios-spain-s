/// A protocol that should implement any Tracker Manager
public protocol TrackerManager {
    func trackScreen(screenId: String, extraParameters: [String: String])
    func trackEvent(screenId: String, eventId: String, extraParameters: [String: String])
    func trackEmma(token: String)
}

// MARK: - Deprecated

@available(*, deprecated, message: "Use AutomaticScreenTrackable instead")
public protocol TrackerScreenProtocol {
    var screenId: String? { get }
    var emmaScreenToken: String? { get }
    func getTrackParameters() -> [String: String]?
}

extension ScreenTrackable where Self: TrackerScreenProtocol {
    
    public func trackScreen() {
        guard let screenId = self.screenId else { return }
        trackerManager.trackScreen(screenId: screenId, extraParameters: getTrackParameters() ?? [:])
    }
}

// MARK: - Trackable protocols

/// A protocol that should implement any screen with the capability of being trackable
public protocol ScreenTrackable {
    var trackerManager: TrackerManager { get }
    func getTrackParameters() -> [String: String]?
}

extension ScreenTrackable {
    
    public func getTrackParameters() -> [String: String]? {
        return nil
    }
}

/// A protocol that should implement any screen with the capability of being trackable automatically
public protocol AutomaticScreenTrackable: ScreenTrackable {
    associatedtype Page: PageTrackable
    var trackerPage: Page { get }
}

extension AutomaticScreenTrackable {
    
    public func trackScreen() {
        trackerManager.trackScreen(screenId: trackerPage.page, extraParameters: getTrackParameters() ?? [:])
    }
}

/// A protocol that should implement any screen with the capability of being trackable automatically (with Emma token too)
public protocol AutomaticScreenEmmaTrackable: ScreenTrackable {
    associatedtype Page: PageTrackable & EmmaTrackable
    var trackerPage: Page { get }
}

extension AutomaticScreenEmmaTrackable {
    
    public func trackScreen() {
        trackerManager.trackScreen(screenId: trackerPage.page, extraParameters: getTrackParameters() ?? [:])
        trackerManager.trackEmma(token: trackerPage.emmaToken)
    }
}

/// A protocol that should implement any screen with the capability of being trackable automatically and have actions
public protocol AutomaticScreenActionTrackable: ScreenTrackable {
    associatedtype Page: PageWithActionTrackable
    var trackerPage: Page { get }
}

extension AutomaticScreenActionTrackable {
    
    public func trackScreen() {
        trackerManager.trackScreen(screenId: trackerPage.page, extraParameters: getTrackParameters() ?? [:])
    }
}

extension AutomaticScreenActionTrackable where Page.ActionType: RawRepresentable, Page.ActionType.RawValue == String {
    
    public func trackEvent(_ action: Page.ActionType, parameters: [TrackerDimension: String]) {
        let extraParameters = parameters.map({ ($0.key, $1) })
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: action.rawValue, extraParameters: extraParameters.reduce(into: [:], { $0[$1.0] = $1.1 }))
    }
    
    public func trackEvent(_ action: Page.ActionType, parameters: [String: String]? = nil) {
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: action.rawValue, extraParameters: parameters ?? [:])
    }
}

/// A protocol that should implement any screen with the capability of being trackable automatically and have actions (with Emma token too)
public protocol AutomaticScreenEmmaActionTrackable: ScreenTrackable {
    associatedtype Page: PageWithActionTrackable & EmmaTrackable
    var trackerPage: Page { get }
}

extension AutomaticScreenEmmaActionTrackable {
    
    public func trackScreen() {
        trackerManager.trackScreen(screenId: trackerPage.page, extraParameters: getTrackParameters() ?? [:])
        trackerManager.trackEmma(token: trackerPage.emmaToken)
    }
}

extension AutomaticScreenEmmaActionTrackable where Page.ActionType: RawRepresentable, Page.ActionType.RawValue == String {
    
    public func trackEvent(_ action: Page.ActionType, parameters: [TrackerDimension: String]) {
        let extraParameters = parameters.map({ ($0.key, $1) })
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: action.rawValue, extraParameters: extraParameters.reduce(into: [:], { $0[$1.0] = $1.1 }))
    }
}

/// A page tracklable entity
public protocol PageTrackable {
    var page: String { get }
}

/// Emma trackable entity
public protocol EmmaTrackable {
    var emmaToken: String { get }
}

/// A page trackable entity that have any action to track
public protocol PageWithActionTrackable: PageTrackable {
    associatedtype ActionType = CaseIterable
}

/// Page value when reusing classes
public protocol TrackerPageAssociated {
    var pageAssociated: String { get }
}
