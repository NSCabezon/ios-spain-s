import CoreFoundationLib
import WebViews

enum InboxTabList {
    
    case onlineMessages(config: WebViewConfiguration, linkHandler: WebViewLinkHandler)
    
    var rawValue: Int {
        switch self {
        case .onlineMessages:
            return 2
        }
    }
}
