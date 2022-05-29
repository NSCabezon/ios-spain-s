//
//  BaseWebViewNavigatableLauncher.swift
//  RetailLegacy
//
//  Created by Carlos Monfort Gómez on 14/4/21.
//

import Foundation
import CoreFoundationLib
import WebViews

public protocol BaseWebViewNavigatableLauncher {
    func goToWebView(configuration: WebViewConfiguration, type: BaseWebViewNavigatableType?, didCloseClosure: ((Bool) -> Void)?)
    func goToWebView(configuration: WebViewConfiguration, linkHandler: WebViewLinkHandler, didCloseClosure: ((Bool) -> Void)?)
}

public enum BaseWebViewNavigatableType {
    case bizum
    case adobeTarget
}
