import CoreFoundationLib

struct AdobeTargetOfferWebConfiguration: WebViewConfiguration {
    let initialURL: String
    let httpMethod: HTTPMethodType = .post
    let engine: WebViewConfigurationEngine = .webkit
    var queryParameters: [String: String]?
    var bodyParameters: [String: String]?
    let closingURLs: [String]
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    let pdfSource: PdfSource? = .unknown
    let isCachePdfEnabled: Bool = true
    let isFullScreenEnabled: Bool? = false
    var reloadSessionOnClose: Bool = false
}
