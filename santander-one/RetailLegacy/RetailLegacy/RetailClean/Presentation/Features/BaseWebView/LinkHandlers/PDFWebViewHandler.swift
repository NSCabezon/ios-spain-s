import WebViews
import CoreFoundationLib

final class PDFWebViewHandler: BaseWebViewLinkHandler {
    private func isPdfUrl(url: URL?) -> Bool {
        url?.absoluteString.uppercased().contains("PDF") == true
    }

    private enum UrlRedirection {
        case downloadPdf(httpMethod: HTTPMethodType)
        case badURL
        case redirect(URLRequest)

        init?(urlString: String?) {
            var redirection: UrlRedirection?
            guard let url: String = urlString else {
                return nil
            }
            if url.uppercased().contains("APPINTERCEPTOR=PDF") || url.uppercased().contains("PDF=PDF") {
                redirection = url.uppercased().contains("PDFMETHOD=GET") ? .downloadPdf(httpMethod: .get) : .downloadPdf(httpMethod: .post)
            } else if url.uppercased().contains("PDF") {
                redirection = .downloadPdf(httpMethod: .post)
            } else if url.uppercased().contains("METHOD=POST") == true {
                guard var urlComponents: URLComponents = URLComponents(string: url),
                let queryItems: [URLQueryItem] = urlComponents.queryItems  else {
                    return nil
                }
                let queryItemsFiltered: [URLQueryItem] = queryItems.filter { (item: URLQueryItem) -> Bool in
                    return item.name.uppercased() != "REDIRECTION" || item.value?.uppercased() != "POST"
                }
                urlComponents.queryItems = queryItemsFiltered
                let components: String? = urlComponents.query
                urlComponents.query = nil
                guard let source: URL = urlComponents.url else {
                    return nil
                }
                var urlRequest: URLRequest = URLRequest(url: source)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = components?.data(using: String.Encoding.utf8)
                redirection = .redirect(urlRequest)
            }
            if let redirection = redirection {
                self = redirection
            } else {
                return nil
            }
        }
    }

}

extension PDFWebViewHandler: WebViewLinkHandler {
    public func willHandle(url: URL?) -> Bool {
        guard UrlRedirection(urlString: url?.absoluteString) != nil else {
            return false
        }
        return true
    }

    public func shouldLoad(request: URLRequest?, displayLoading: @escaping ((Bool) -> Void)) -> Bool {
        guard let redirection = UrlRedirection(urlString: request?.url?.absoluteString) else {
            return true
        }
        switch redirection {
        case .downloadPdf(let httpMethod):
            self.downloadPdfWithUrl(request?.url, method: httpMethod, displayLoading: displayLoading)
        case .badURL:
            return exitWebViewWhenBack()
        case .redirect(let request):
            delegate?.open(request: request)
        }
        return false
    }
}
