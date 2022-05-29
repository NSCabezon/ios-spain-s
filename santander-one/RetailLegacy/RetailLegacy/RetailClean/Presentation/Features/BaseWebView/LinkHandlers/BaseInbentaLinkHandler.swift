import Foundation
import WebViews

final class ChatInbentaLinkHandler: BaseInbentaLinkHandler, WebViewLinkHandler {
}

final class ManagerWallLinkHandler: BaseInbentaLinkHandler, WebViewLinkHandler {
}

class BaseInbentaLinkHandler: BaseWebViewLinkHandler {
    
    func willHandle(url: URL?) -> Bool {
        return isPdfUrl(url: url)
    }
    
    func shouldLoad(request: URLRequest?, displayLoading: @escaping ((Bool) -> Void)) -> Bool {
        downloadPdfWithRequest(request, displayLoading: displayLoading)
        return false
    }
    
    private func isPdfUrl(url: URL?) -> Bool {
        return url?.absoluteString.contains("action=dc") == true || url?.absoluteString.contains("action=pdf") == true
    }
}
