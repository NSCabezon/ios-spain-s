import CoreFoundationLib

struct PullOffersWebViewConfiguration: WebViewConfiguration {
    let initialURL: String
    let httpMethod: HTTPMethodType
    let queryParameters: [String: String]
    let bodyParameters: [String: String]?
    let closingURLs: [String]
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    let offerId: String?
    let pdfSource: PdfSource? = .unknown
    let engine: WebViewConfigurationEngine
    let timer: Int?
    let isCachePdfEnabled: Bool = false
    let isFullScreenEnabled: Bool?
    let headers: [String: String]?
    var reloadSessionOnClose: Bool = false
}
