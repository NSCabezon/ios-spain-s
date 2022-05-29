import Foundation
import WebViews

class ManagerMarketplaceLinkHandler: BaseWebViewLinkHandler {
}

extension ManagerMarketplaceLinkHandler: WebViewLinkHandler {
    
    func willHandle(url: URL?) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: "https://app.wakup.net(:[0-9]*)?/offers/(.)*/link/(.)*"),
            let stringUrl = url?.absoluteString
            else { return false }
        let range = stringUrl.startIndex..<stringUrl.endIndex
        return regex.firstMatch(in: stringUrl, range: NSRange(range, in: stringUrl)) != nil
    }
    
    func shouldLoad(request: URLRequest?, displayLoading: @escaping ((Bool) -> Void)) -> Bool {
        if let url = request?.url {
            delegate?.displayInSafari(with: url)
        }
        return false
    }
}
