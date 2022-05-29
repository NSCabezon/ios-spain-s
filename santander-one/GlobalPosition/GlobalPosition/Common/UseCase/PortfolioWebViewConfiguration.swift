//
//  ManagedPortfolioWebViewConfiguration.swift
//  GlobalPosition
//
//  Created by Ali Ghanbari Dolatshahi on 12/1/22.
//
import CoreFoundationLib

struct PortfolioWebViewConfiguration: WebViewConfiguration {
    let initialURL: String
    let httpMethod: HTTPMethodType = .post
    var bodyParameters: [String: String]?
    let closingURLs: [String]
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    let pdfSource: PdfSource?
    let engine: WebViewConfigurationEngine = .webkit
    let isCachePdfEnabled: Bool = false
    let isFullScreenEnabled: Bool? = false
    var reloadSessionOnClose: Bool = false
}
