import Foundation
import WebViews

class AdobeTargetOfferLinkHandler: BaseWebViewLinkHandler {}

extension AdobeTargetOfferLinkHandler: WebViewLinkHandler {
    func willHandle(url: URL?) -> Bool {
        return false
    }

    func shouldLoad(request: URLRequest?, displayLoading: @escaping ((Bool) -> Void)) -> Bool {
        if let url = request?.url {
            delegate?.displayInSafari(with: url)
        }
        return false
    }
}
