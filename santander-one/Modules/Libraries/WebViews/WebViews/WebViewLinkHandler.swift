import Foundation
import CoreFoundationLib
import Contacts

public protocol WebViewLinkHandler {
    var configuration: WebViewConfiguration { get }
    var delegate: WebViewLinkHandlerDelegate? { get set }
    func willHandle(url: URL?) -> Bool
    func shouldLoad(request: URLRequest?, displayLoading: @escaping ((Bool) -> Void)) -> Bool
    func willHandleBack(url: URL?) -> Bool
    func handleBack(url: URL?)
    func willHandleClose(url: URL?) -> Bool
    func handleClose(url: URL?)
}

public extension WebViewLinkHandler {
    func willHandleBack(url: URL?) -> Bool {
        return false
    }
    
    func handleBack(url: URL?) {}
    
    func willHandleClose(url: URL?) -> Bool {
        return false
    }
    
    func handleClose(url: URL?) {}
}

public enum WebViewLinkHandlerDelegateErrorAction {
    case goToSettings
}

public protocol WebViewLinkHandlerDelegate: AnyObject {
    func displayPDF(with data: Data)
    func displayError(title: LocalizedStylableText?, message: LocalizedStylableText?, action: WebViewLinkHandlerDelegateErrorAction?, showCancel: Bool)
    func showContacts(selected: @escaping ([UserContactRepresentable]) -> Void)
    func inject(javascript: String)
    func openImageSelection(selected: @escaping (Data) -> Void)
    func openCamera(selected: @escaping (Data) -> Void)
    func openGallery(selected: @escaping (Data) -> Void)
    func displayInSafari(with url: URL)
    func exitWebView(reloadGlobalPosition: Bool, goToDeepLink: DeepLink?)
    func openApp(scheme: String?, identifier: Int)
    //! Exit from webview when the user go back on navigator. Special conditions
    func exitWebViewWhenBack() -> Bool
    func open(deepLink: DeepLink)
    func open(request: URLRequest)
    func showLoading()
}

public extension WebViewLinkHandlerDelegate {
    func exitWebView(reloadGlobalPosition: Bool, goToDeepLink: DeepLink? = nil) {
        exitWebView(reloadGlobalPosition: reloadGlobalPosition, goToDeepLink: goToDeepLink)
    }
}
