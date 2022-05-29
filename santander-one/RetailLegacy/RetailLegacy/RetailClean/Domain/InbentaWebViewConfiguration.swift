import CoreFoundationLib

struct InbentaWebViewConfiguration: WebViewConfiguration {
    let initialURL: String
    let httpMethod: HTTPMethodType = .post
    let bodyParameters: [String: String]?
    let closingURLs: [String]
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    let pdfSource: PdfSource?
    let engine: WebViewConfigurationEngine = .custom(engine: "uiwebview")
    let isForceCloseLoadingTips: Bool = true
    let isCachePdfEnabled: Bool = true
    let isFullScreenEnabled: Bool? = false
    var reloadSessionOnClose: Bool = false
}
