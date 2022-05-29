import CoreFoundationLib

public struct BizumWebViewConfiguration: WebViewConfiguration {
    public let initialURL: String
    public let httpMethod: HTTPMethodType
    public let bodyParameters: [String: String]?
    public let closingURLs: [String]
    public let webToolbarTitleKey: String?
    public let pdfToolbarTitleKey: String?
    public let pdfSource: PdfSource?
    public let engine: WebViewConfigurationEngine
    public let isCachePdfEnabled: Bool
    public let isFullScreenEnabled: Bool? = false
    public var reloadSessionOnClose: Bool = true
    
    public init(initialURL: String,
                bodyParameters: [String: String]?,
                closingURLs: [String],
                webToolbarTitleKey: String?,
                pdfToolbarTitleKey: String?) {
        self.initialURL = initialURL
        self.httpMethod = .post
        self.bodyParameters = bodyParameters
        self.closingURLs = closingURLs
        self.webToolbarTitleKey = webToolbarTitleKey
        self.pdfToolbarTitleKey = pdfToolbarTitleKey
        self.pdfSource = .bizum
        self.engine = .custom(engine: "uiwebview")
        self.isCachePdfEnabled = false
    }
}
