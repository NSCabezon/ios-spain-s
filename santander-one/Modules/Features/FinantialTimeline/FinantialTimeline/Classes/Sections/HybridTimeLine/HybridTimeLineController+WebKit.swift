//
//  HybridTimeLineController+WebKit.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 19/09/2019.
//

import Foundation
import WebKit


extension HybridTimeLineController {
    func setWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.insertSubview(webView, at: 0)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    func loadWebView() {
        guard let thisUrl = getURLQuery() else { return }
        startLoading()
        let req = URLRequest(url: thisUrl)
        webView.load(req)
    }
}

// MARK: - WKUIDelegate
extension HybridTimeLineController: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let statusCode = (navigationResponse.response as? HTTPURLResponse)?.statusCode else {
            decisionHandler(.cancel)
            onLoadError()
            return
        }
        
        switch statusCode {
        case 200:
            decisionHandler(.allow)
        default:
            decisionHandler(.cancel)
            onLoadError()
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "close" {
            self.onBackPressed()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoadSucces()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onLoadError()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onLoadError()
    }
}
