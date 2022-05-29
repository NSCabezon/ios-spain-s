import SafariServices
import CoreFoundationLib
import WebKit
import WebViews

extension WKWebView: WebView {
    
    public func setup() {
        guard let webViewDelegate = webViewDelegate else { return }
        JavascriptAction.allCases.forEach {
            guard let messageHandler = webViewDelegate as? WKScriptMessageHandler else { return }
            self.configuration.userContentController.add(messageHandler, name: $0.rawValue)
        }
    }
    
    public var webViewDelegate: BaseWebViewDelegate? {
        get {
            return self.navigationDelegate as? WKWebViewDelegate
        }
        set {
            self.uiDelegate = newValue as? WKWebViewDelegate
            self.navigationDelegate = newValue as? WKWebViewDelegate
        }
    }
    
    public var view: UIView {
        return self
    }
    
    public func loadRequest(_ request: URLRequest) {
        if let userAgent = request.value(forHTTPHeaderField: "User-Agent") {
            debugPrint(userAgent)
            customUserAgent = userAgent
        }
        load(request)
    }
    
    public func back() {
        goBack()
    }
    
    public func stringByEvaluatingJavaScript(from javascript: String, completion: ((Any?, Error?) -> Void)?) {
        evaluateJavaScript(javascript, completionHandler: completion)
    }
}

class WKWebViewDelegate: NSObject, BaseWebViewDelegate {
    
    weak var loadingAreaProvider: LoadingAreaProvider?
    weak var loadingHandler: LoadingHandlerDelegate?
    weak var webViewNavigationDelegate: WebViewNavigationDelegate?
    weak var webViewLoader: WebViewLoader?
    var linkHandler: WebViewLinkHandler?
    var javascriptHandler: WebViewJavascriptHandler?
    var secondTime: Bool = false
    var isLoading: Bool = false
    var webRequest: URLRequest?
    var currentUrl: URL?
    private let compilation: CompilationProtocol
    
    required init?(dependenciesResolver: DependenciesResolver?) {
        guard let dependenciesResolver = dependenciesResolver else { return nil }
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        HTTPCookieStorage.shared.cookies?.forEach({ (cookie) in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        })
    }
}

// MARK: - WKWebView

extension WKWebViewDelegate: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.loadRequest(navigationAction.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webViewDidStartLoad()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webViewDidFail(withError: error)
    }
    
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        webViewDidFail(withError: error)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           let queryParamValue = url.valueForQueryParam(withName: "external"),
           queryParamValue == "1",
           UIApplication.shared.canOpen(url: url) {
            UIApplication.shared.open(url: url)
            decisionHandler(.cancel)
            return
        }
        if let phoneUrl = navigationAction.request.url, phoneUrl.scheme == "tel" {
            UIApplication.shared.open(url: phoneUrl)
            decisionHandler(.cancel)
            return
        }
        if
            let frame = navigationAction.targetFrame,
            frame.isMainFrame,
            let headers = linkHandler?.configuration.headers,
            !requestHasHeaders(headers: headers, request: navigationAction.request) {
            decisionHandler(.cancel)
            let requestWithAddedHeaders = addHeaders(headers: headers, request: navigationAction.request)
            webView.loadRequest(requestWithAddedHeaders)
        } else {
            let shouldStart = shouldStartLoad(request: navigationAction.request)
            decisionHandler(shouldStart == true ? .allow : .cancel)
        }
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        webViewDidFinish(withURL: navigationResponse.response.url)
        guard
            let response = navigationResponse.response as? HTTPURLResponse,
            let allHttpHeaders = response.allHeaderFields as? [String: String],
            let responseUrl = response.url
        else {
            return decisionHandler(.allow)
        }
        let onCookiesReceived: ([HTTPCookie]) -> Void = { (cookies: [HTTPCookie]) in
            cookies.forEach(HTTPCookieStorage.shared.setCookie)
            decisionHandler(.allow)
        }
        if #available(iOS 11.0, *) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies(onCookiesReceived)
        } else {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHttpHeaders, for: responseUrl)
            onCookiesReceived(cookies)
        }
    }

    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        #if INSECURE_WEBVIEWS
            completionHandler(.useCredential, challenge.protectionSpace.serverTrust.map(URLCredential.init))
        #else
            if compilation.isTrustInvalidCertificateEnabled && challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                completionHandler(.useCredential, challenge.protectionSpace.serverTrust.map(URLCredential.init))
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        #endif

    }
}

extension WKWebViewDelegate: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let body = message.body as? String else { return }
        let javascriptMessage = JavascriptMessage(name: message.name, body: body)
        self.javascriptHandler?.handleReceived(message: javascriptMessage)
    }
}
