import CoreFoundationLib

struct VirtualAssistantWebViewConfiguration: WebViewConfiguration {
    let initialURL: String
    let httpMethod: HTTPMethodType = .get
    let closingURLs: [String]
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    let pdfSource: PdfSource? = .unknown
    let engine: WebViewConfigurationEngine = .webkit
    let isCachePdfEnabled: Bool = true
    let isFullScreenEnabled: Bool? = false
    var reloadSessionOnClose: Bool = false
}
