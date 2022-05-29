import UIKit

public protocol UrlActionsCapable {
    func open(_ url: URL)
    func canOpen(_ url: URL) -> Bool
}

public extension UrlActionsCapable {
    func open(_ url: URL) {
        UIApplication.shared.open(url: url)
    }
    
    func canOpen(_ url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }
}
