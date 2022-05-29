//
//  WebViewsProtocols.swift
//  WebView
//
//  Created by José María Jiménez Pérez on 27/05/2021.
//

import CoreFoundationLib
import UI
import CoreFoundationLib

public protocol WebView: AnyObject {
    var webViewDelegate: BaseWebViewDelegate? { get set }
    var canGoBack: Bool { get }
    var scrollView: UIScrollView { get }
    var view: UIView { get }
    func loadRequest(_ request: URLRequest)
    func stringByEvaluatingJavaScript(from javascript: String, completion: ((Any?, Error?) -> Void)?)
    func back()
    init(frame: CGRect)
    func setup()
}

public struct WebViewProviderConfiguration {
    public let webView: WebView
    public let delegate: BaseWebViewDelegate
    
    public init(webView: WebView, delegate: BaseWebViewDelegate) {
        self.webView = webView
        self.delegate = delegate
    }
}

public protocol LoadingAreaProvider: AnyObject {
    var loadingArea: LoadingViewType { get }
}

public protocol WebViewLoader: AnyObject {
    func loadRequest(_ request: URLRequest)
}

public protocol WebViewNavigationDelegate: AnyObject {
    var closingURLs: [String] { get }
    var globalPositionClosingURLs: [String] { get }
    func didHitClosingURL(url: String, goToDeepLink: DeepLink?)
}

public extension WebViewNavigationDelegate {
    func didHitClosingURL(url: String, goToDeepLink: DeepLink? = nil) {
        didHitClosingURL(url: url, goToDeepLink: goToDeepLink)
    }
}

public protocol LoadingHandlerDelegate: AnyObject {
    func hideLoading()
}

public protocol BaseWebViewDelegate: AnyObject {
    var loadingAreaProvider: LoadingAreaProvider? { get set }
    var webViewNavigationDelegate: WebViewNavigationDelegate? { get set }
    var linkHandler: WebViewLinkHandler? { get set }
    var javascriptHandler: WebViewJavascriptHandler? { get set }
    var loadingHandler: LoadingHandlerDelegate? { get set }
    var isLoading: Bool { get set }
    var secondTime: Bool { get set }
    var currentUrl: URL? { get set }
    var webRequest: URLRequest? { get set }
    var webViewLoader: WebViewLoader? { get set }
    func willHandleBack() -> Bool
    func handleBack()
    func willHandleClose() -> Bool
    func handleClose()
    init?(dependenciesResolver: DependenciesResolver?)
}

public protocol WebViewProviderProtocol {
    func provideWebViewForEngineWithKey(_ key: String) -> WebViewProviderConfiguration?
}

public extension BaseWebViewDelegate {
    
    func webViewDidStartLoad() {
        displayLoading()
    }
    
    func webViewDidFail(withError error: Error) {
        currentUrl = nil
        hideLoading()
    }
    
    func webViewDidFinish(withURL url: URL?) {
        currentUrl = url
        hideLoading()
    }
    
    func webViewShouldLoad(_ request: URLRequest) -> Bool {
        if shouldStartLoad(request: request) {
            webRequest = request
            return true
        } else {
            webRequest = nil
            return false
        }
    }
}

public extension BaseWebViewDelegate {
    
    func shouldStartLoad(request: URLRequest) -> Bool {
        func isClosingUrl(urlString: String) -> Bool {
            let found = webViewNavigationDelegate?.closingURLs.first {
                guard var url = URL(string: $0)?.absoluteString else {
                    return false
                }
                if URL(string: $0)?.hasDirectoryPath == true {
                    url = String($0.dropLast())
                }
                return urlString.contains(url)
            }
            return found != nil
        }
        
        func isGlobalPositionClosingUrl(urlString: String) -> Bool {
            let found = webViewNavigationDelegate?.globalPositionClosingURLs.first {
                guard var url = URL(string: $0)?.absoluteString else {
                    return false
                }
                if URL(string: $0)?.hasDirectoryPath == true {
                    url = String($0.dropLast())
                }
                return urlString.contains(url)
            }
            return found != nil
        }
        guard var urlString = request.url?.absoluteString else {
            return true
        }
        let isLinkHandlerUrl = linkHandler?.willHandle(url: request.url) ?? false
        if request.url?.hasDirectoryPath == true {
            urlString = String(urlString.dropLast())
        }
        if isClosingUrl(urlString: urlString) {
            if linkHandler?.willHandleClose(url: request.url) == true {
                linkHandler?.handleClose(url: request.url)
            } else {
                webViewNavigationDelegate?.didHitClosingURL(url: urlString)
            }
            return false
        } else if isGlobalPositionClosingUrl(urlString: urlString) {
            webViewNavigationDelegate?.didHitClosingURL(url: urlString, goToDeepLink: .globalPosition)
            return false
        } else if isLinkHandlerUrl {
            return linkHandler?.shouldLoad(request: request, displayLoading: displayLoading) ?? true
        }
        return true
    }
    
    func hideLoading() {
        if isLoading {
            isLoading = false
            loadingHandler?.hideLoading()
        }
    }
    
    func displayLoading(_ isLoading: Bool) {
        if !isLoading {
            self.isLoading = true
        } else {
            hideLoading()
        }
    }
    
    func displayLoading() {
        if !isLoading, !secondTime {
            isLoading = true
            secondTime = true
        }
    }
    
    func requestHasHeaders(headers: [String: String], request: URLRequest) -> Bool {
        var requestHasHeaders = false
        headers.forEach {
            requestHasHeaders = request.value(forHTTPHeaderField: $0.key) == $0.value
        }
        return requestHasHeaders
    }
    
    func addHeaders(headers: [String: String], request: URLRequest) -> URLRequest {
        var newRequest = request
        headers.forEach {
            newRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        return newRequest
    }
}

public extension BaseWebViewDelegate {
    
    func willHandleBack() -> Bool {
        return linkHandler?.willHandleBack(url: currentUrl) == true
    }
    
    func handleBack() {
        linkHandler?.handleBack(url: currentUrl)
    }
    
    func willHandleClose() -> Bool {
        linkHandler?.willHandleClose(url: currentUrl) == true
    }
    
    func handleClose() {
        linkHandler?.handleClose(url: currentUrl)
    }
}
