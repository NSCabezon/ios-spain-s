import CoreFoundationLib

struct PushNotificationsWebViewConfiguration: WebViewConfiguration {
    let initialURL: String
    let httpMethod: HTTPMethodType = .get
    var bodyParameters: [String: String]?
    let closingURLs: [String]
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    var pdfSource: PdfSource?
    let engine: WebViewConfigurationEngine = .webkit
    let isCachePdfEnabled: Bool = false
    let isFullScreenEnabled: Bool? = false
    var reloadSessionOnClose: Bool = false
}
