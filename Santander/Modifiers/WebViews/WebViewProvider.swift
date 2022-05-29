//
//  WebViewProvider.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 27/5/21.
//

import Foundation
import WebViews
import CoreFoundationLib

final class WebViewProvider {
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
    
extension WebViewProvider: WebViewProviderProtocol {
    func provideWebViewForEngineWithKey (_ key: String) -> WebViewProviderConfiguration? {
        if let webViewType = SpainWebViews(string: key) {
            switch webViewType {
            case .uiwebview:
                guard let delegate = WebViewDelegate(dependenciesResolver: dependenciesResolver) else { return nil }
                return WebViewProviderConfiguration(webView: UIWebView(frame: .zero), delegate: delegate)
            }
        }
        return nil
    }
}
