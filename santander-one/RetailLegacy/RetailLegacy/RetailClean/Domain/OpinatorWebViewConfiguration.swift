import CoreFoundationLib

public struct OpinatorWebViewConfiguration: WebViewConfiguration {
    public var initialURL: String
    public var httpMethod: HTTPMethodType = .get
    public var queryParameters: [String: String]
    public var closingURLs: [String]
    public var webToolbarTitleKey: String?
    public let pdfToolbarTitleKey: String?
    public let pdfSource: PdfSource? = .unknown
    public let engine: WebViewConfigurationEngine = .webkit
    public let isCachePdfEnabled: Bool = false
    public let isFullScreenEnabled: Bool? = false
    public var reloadSessionOnClose: Bool = false
    public var showBackButton: Bool = true
    public var showBackNavigationItem: Bool { showBackButton }
}
