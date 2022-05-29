//
//  WebViewDelegate.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 27/5/21.
//

import Foundation
import WebViews
import ESCommons
import CoreFoundationLib

extension UIWebView: WebView {
    
    public func setup() {
       self.keyboardDisplayRequiresUserAction = false
    }
    
    public var webViewDelegate: BaseWebViewDelegate? {
        get {
            return self.delegate as? WebViewDelegate
        }
        set {
            self.delegate = newValue as? WebViewDelegate
        }
    }
    
    public var view: UIView {
        return self
    }
    
    public func back() {
        goBack()
    }
    
    public func stringByEvaluatingJavaScript(from javascript: String, completion: ((Any?, Error?) -> Void)?) {
        let result = stringByEvaluatingJavaScript(from: javascript)
        completion?(result, nil)
    }
}

public class WebViewDelegate: NSObject, BaseWebViewDelegate {
    
    private var _authenticated: [String: Bool] = ["www.youtube.com": true, "micomercio.santanderempresas.mobi": true] // setting to avoid the youtube video redirection
    private var failedRequest: URLRequest?
    
    public weak var loadingAreaProvider: LoadingAreaProvider?
    public weak var loadingHandler: LoadingHandlerDelegate?
    public weak var webViewNavigationDelegate: WebViewNavigationDelegate?
    public weak var webViewLoader: WebViewLoader?
    public var linkHandler: WebViewLinkHandler?
    public var javascriptHandler: WebViewJavascriptHandler?
    
    public var secondTime: Bool = false
    public var isLoading: Bool = false
    public var webRequest: URLRequest?
    public var currentUrl: URL?
    
    private let compilation: CompilationProtocol
    
    public required init?(dependenciesResolver: DependenciesResolver?) {
        guard let dependenciesResolver = dependenciesResolver else { return nil }
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
}

// MARK: - UIWebViewDelegate

extension WebViewDelegate: UIWebViewDelegate {
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        webViewDidStartLoad()
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        webViewDidFinish(withURL: webView.request?.url)
        guard
            let allHttpHeaders = webView.request?.allHTTPHeaderFields,
            let responseUrl = webView.request?.url
        else {
            return
        }
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHttpHeaders, for: responseUrl)
        cookies.forEach(HTTPCookieStorage.shared.setCookie)
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        return webViewShouldLoad(request)
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if compilation.isTrustInvalidCertificateEnabled, checkSSLErrorCodes(error: error as NSError), let request = webRequest, let host = request.url?.host, _authenticated[host] == nil {
            webRequest = nil
            failedRequest = request
            _ = NSURLConnection(request: request, delegate: self)
        } else {
            webViewDidFail(withError: error)
        }
    }
}

// MARK: - NSURLConnectionDelegate, NSURLConnectionDataDelegate

extension WebViewDelegate: NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    public func connection(_ connection: NSURLConnection, willCacheResponse cachedResponse: CachedURLResponse) -> CachedURLResponse? {
        return nil
    }
    
    public func connection(_ connection: NSURLConnection, willSendRequestFor challenge: URLAuthenticationChallenge) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let serverTrust = challenge.protectionSpace.serverTrust!
            let exceptions = SecTrustCopyExceptions(serverTrust)
            SecTrustSetExceptions(serverTrust, exceptions)
            challenge.sender?.use(URLCredential(trust: serverTrust), for: challenge)
        } else {
            challenge.sender?.performDefaultHandling?(for: challenge)
        }
    }
    
    public func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        if let host = connection.currentRequest.url?.host {
            _authenticated[host] = true
        }
        connection.cancel()
        if let failedRequest = failedRequest {
            webViewLoader?.loadRequest(failedRequest)
        } else {
            hideLoading()
        }
    }
    
    public func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        webViewDidFail(withError: error)
    }
}

// MARK: - Private methods

private extension WebViewDelegate {
    
    func checkSSLErrorCodes(error: NSError) -> Bool {
        switch error.code {
        case NSURLErrorSecureConnectionFailed, NSURLErrorSecureConnectionFailed, NSURLErrorServerCertificateHasBadDate, NSURLErrorServerCertificateUntrusted, NSURLErrorServerCertificateHasUnknownRoot, NSURLErrorServerCertificateNotYetValid, NSURLErrorClientCertificateRejected, NSURLErrorClientCertificateRequired, NSURLErrorCannotLoadFromNetwork:
            return true
        default:
            return false
        }
    }
}
