import Foundation
import WebViews

class OnlineMessagesLinkHandler: BaseWebViewLinkHandler, WebViewLinkHandler {
    
    func willHandle(url: URL?) -> Bool {
        return isPdfUrl(url: url)
    }
    
    func shouldLoad(request: URLRequest?, displayLoading: @escaping ((Bool) -> Void)) -> Bool {
        downloadPdfWithRequest(request, displayLoading: displayLoading)
        return false
    }
    
    private func isPdfUrl(url: URL?) -> Bool {
        return url?.absoluteString.contains("visualizarComunicado") == true
    }
}
