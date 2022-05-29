//  ANALYTICS REMOVED
//import Foundation
//import GlobileSquadsCore
//
//public enum BlKeys: String{
//    case eventAction = "EventAction"
//    case screenName = "ScreenName"
//    case component = "Component"
//    
//    case branchATMName = "branchAtmName"
//    case branchATMType = "branchAtmType"
//    case tabName = "TabName"
//    case openMapOrigin = "OpenMapOrigin"
//    case termSearched = "TermSearched"
//    case clickedResult = "ClickedResult"
//    case numberSearchResult = "NSearchResult"
//    case filterSelected = "FilterSelected"
//}
//
//public enum BlEvent: String {
//    // Views
//    case homeView = "branch locator:home"
//    case detailView = "branch locator:detail"
//    case filtersView = "branch locator:filters"
//    case listView = "branch locator:listing"
//    case searchView = "branch locator:search"
//    //events
//    case tapSearchBar = "tap search bar"
//    case tapFilters = "tap filters"
//    case tapBranchDetail = "tap branch detail"
//    case tapBranchPicker = "tap branch picker"
//    case tapBranchIcon = "tap branch icon"
//    case tapOpenMap = "tap open map"
//    case tapOnCallButton = "tap on call button"
//    case searchedInSearchBar = "search"        // how many final searches have occurred in the component's search bar and text searched
//    case tapSearchResult = "tap search result"
//    case tapClean = "tap clean filters"
//    case tapApplyFilters = "tap apply filters"                        // how many times a filter change has been applied and which ones have been activated and which ones have been deactivated
//    case seeMoreButton = "tap see more"
//
//}
//
//
//class BLAnalyticsHandler {
//    static var analyticsDelegate: GlobileAnalyticsDelegate?
//
//    static private var componentName = "branch locator"
//
//
//    static private var componentVersion: String {
//        let defaultVersion = "2.1.2"
//        let mainBundle = Bundle(for: MapViewController.self)
//
//        guard let podBundleURL = mainBundle.url(forResource: "BranchLocator", withExtension: "bundle"),
//            let podBundle = Bundle(url: podBundleURL) else { return defaultVersion }
//
//        return podBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? defaultVersion
//    }
//
//    class func track(event: BlEvent, screenName: String, isScreen: Bool) {
//        sendToAnalytics(eventString: event.rawValue, screenName: screenName, isScreen: isScreen)
//    }
//
//    class func trackFilterEvent(with filters: [Filter], screenName: String, isScreen: Bool) {
//        let filtersString = filters.map({ $0.rawValue })
//        sendToAnalytics(eventString: BlEvent.tapApplyFilters.rawValue,
//                               screenName: screenName,
//                               parameters: [BlKeys.filterSelected.rawValue: filtersString],
//                               isScreen: isScreen)
//    }
//
//    class func track(event: BlEvent, screenName: String, with params: [String: Any], isScreen: Bool) {
//        sendToAnalytics(eventString: event.rawValue, screenName: screenName, parameters: params, isScreen: isScreen)
//    }
//
//    class func sendToAnalytics(eventString: String, screenName: String, parameters: [String: Any]? = nil, isScreen: Bool) {
//        if isScreen {
//            analyticsDelegate?.track(metric: .view(name: eventString, component: "a", componentName: componentName, componentVersion: componentVersion, screen: screenName, params: parameters ?? [:]))
//        } else {
//            analyticsDelegate?.track(metric: .event(name: eventString, component: "a", componentName: componentName, componentVersion: componentVersion, screen: screenName, params: parameters ?? [:]))
//        }
//    }
//}
