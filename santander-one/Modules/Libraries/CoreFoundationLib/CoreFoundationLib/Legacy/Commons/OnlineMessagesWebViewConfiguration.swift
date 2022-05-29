//
//  OnlineMessagesWebViewConfiguration.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 1/21/20.
//

import Foundation

public struct OnlineMessagesWebViewConfiguration: WebViewConfiguration {
    public var initialURL: String
    public var httpMethod: HTTPMethodType = .post
    public var bodyParameters: [String: String]?
    public var closingURLs: [String] = []
    public var webToolbarTitleKey: String?
    public var pdfToolbarTitleKey: String?
    public var pdfSource: PdfSource? = .unknown
    public var engine: WebViewConfigurationEngine = .webkit
    public let isCachePdfEnabled: Bool = false
    public let isFullScreenEnabled: Bool? = false
    public var reloadSessionOnClose: Bool = false
    
    public init(initialURL: String,
                httpMethod: HTTPMethodType = .post,
                bodyParameters: [String: String]? = nil,
                closingURLs: [String] = [],
                webToolbarTitleKey: String? = nil,
                pdfToolbarTitleKey: String? = nil,
                pdfSource: PdfSource? = .unknown) {
        
        self.initialURL = initialURL
        self.httpMethod = httpMethod
        self.bodyParameters = bodyParameters
        self.closingURLs = closingURLs
        self.webToolbarTitleKey = webToolbarTitleKey
        self.pdfToolbarTitleKey = pdfToolbarTitleKey
        self.pdfSource = pdfSource
    }
}
