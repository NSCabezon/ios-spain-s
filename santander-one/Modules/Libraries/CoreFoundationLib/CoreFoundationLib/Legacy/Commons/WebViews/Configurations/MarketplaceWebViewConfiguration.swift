import CoreFoundationLib

public struct MarketplaceWebViewConfiguration: WebViewConfiguration {
    public let initialURL: String
    public let httpMethod: HTTPMethodType = .post
    public var bodyParameters: [String: String]?
    public let closingURLs: [String]
    public let webToolbarTitleKey: String?
    public let pdfToolbarTitleKey: String?
    public let pdfSource: PdfSource?
    public let engine: WebViewConfigurationEngine = .webkit
    public let isCachePdfEnabled: Bool = false
    public let isFullScreenEnabled: Bool? = false
    public var reloadSessionOnClose: Bool = false
    
    public init(initialURL: String,
                bodyParameters: [String: String]?,
                closingURLs: [String],
                webToolbarTitleKey: String?,
                pdfToolbarTitleKey: String?,
                pdfSource: PdfSource?) {
        self.initialURL = initialURL
        self.bodyParameters = bodyParameters
        self.closingURLs = closingURLs
        self.webToolbarTitleKey = webToolbarTitleKey
        self.pdfToolbarTitleKey = pdfToolbarTitleKey
        self.pdfSource = pdfSource
    }
}
