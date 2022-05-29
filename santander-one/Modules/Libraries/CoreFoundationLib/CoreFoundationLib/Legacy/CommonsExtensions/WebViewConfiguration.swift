//
//  WebViewConfiguration.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 1/21/20.
//

import Foundation
import WebKit

public enum PdfSource {
    case chatInbenta
    case accountTransactionDetail
    case cardTransactionsDetail
    case cardPDFExtract
    case bizum
    case nosepa
    case summary
    case accountHome
    case transferSummary
    case bill
    case sanflix
    case partialAmortization(String)
    case unknown
}

public enum WebViewConfigurationEngine {
    case webkit
    case custom(engine: String)
    
    public init(string: String) {
        switch string {
        case "wkwebview": self = .webkit
        default: self = .custom(engine: string)
        }
    }
}

public protocol WebViewConfiguration {
    var initialURL: String { get }
    var httpMethod: HTTPMethodType { get }
    var request: URLRequest? { get }
    var headers: [String: String]? { get }
    var closingURLs: [String] { get }
    var globalPositionClosingURLs: [String] { get }
    var queryParameters: [String: String] { get }
    var bodyParameters: [String: String]? { get }
    var webToolbarTitleKey: String? { get }
    var pdfToolbarTitleKey: String? { get }
    var engine: WebViewConfigurationEngine { get }
    // ! PDF source if so
    var pdfSource: PdfSource? { get }
    var timer: Int? { get }
    var isForceCloseLoadingTips: Bool { get }
    var isCachePdfEnabled: Bool { get }
    var isFullScreenEnabled: Bool? { get }
    var showBackNavigationItem: Bool { get }
    var showRightCloseNavigationItem: Bool { get }
    var reloadSessionOnClose: Bool { get set }
}

public extension WebViewConfiguration {
    
    var timer: Int? { nil }
    
    var request: URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let body = body {
            request.httpBody = body
            if httpMethod != .get {
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
        }
        headers?.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        request.setValue("\(userAgent)[NATIVE/ONEAPP]", forHTTPHeaderField: "User-Agent")
        return request
    }
    
    var headers: [String: String]? { nil }
    
    var url: URL? {
        let basicUrl = initialURL.trim()
        var urlComponents = URLComponents(string: basicUrl)
        var urlQueryItems = urlComponents?.queryItems ?? []
        urlQueryItems.removeAll(where: { $0.name == self.fullScreenEnabledParameter })
        urlQueryItems += queryParameters.compactMap { URLQueryItem(name: $0, value: $1) }
        urlComponents?.queryItems = urlQueryItems
        return urlComponents?.url
    }
    
    var httpMethod: HTTPMethodType {
        return .get
    }
    
    var closingURLs: [String] {
        return []
    }
    
    var globalPositionClosingURLs: [String] {
        return []
    }
    
    var bodyParameters: [String: String]? {
        return nil
    }
    
    var queryParameters: [String: String] {
        return [:]
    }
    
    var isForceCloseLoadingTips: Bool {
        return false
    }
    
    var showBackNavigationItem: Bool {
        return true
    }
    
    var showRightCloseNavigationItem: Bool {
        return true
    }

    var isFullScreen: Bool {
        let urlComponents = URLComponents(string: self.initialURL)
        let isFullScreenQueryParam = urlComponents?.queryItems?.first(where: {$0.name == self.fullScreenEnabledParameter})?.value == "true"
        return self.isFullScreenEnabled ?? false || isFullScreenQueryParam
    }
    
    private var userAgent: String {
        return WKWebView().value(forKey: "userAgent") as? String ?? "unknown"
    }

    private var body: Data? {
        let bodyString = bodyParameters?.compactMap({ return "\($0)=\($1)" }).joined(separator: "&")
        return bodyString?.data(using: .utf8)
    }

    private var fullScreenEnabledParameter: String {
        return "isFullScreenEnabled"
    }
}

public enum HTTPMethodType: String {
    case post = "POST"
    case get = "GET"
}
