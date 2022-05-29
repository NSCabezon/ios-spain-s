import CoreFoundationLib

struct SantanderAppsWebViewConfiguration: WebViewConfiguration {
    let initialURL: String
    let httpMethod: HTTPMethodType = .get
    let queryParameters: [String: String]
    let closingURLs: [String]
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    let pdfSource: PdfSource? = .unknown
    let engine: WebViewConfigurationEngine = .webkit
    let isCachePdfEnabled: Bool = false
    let isFullScreenEnabled: Bool? = false
    var reloadSessionOnClose: Bool = false
}
