import Foundation

public extension URL {
    func starts(with url: URL) -> Bool {
        return self.absoluteString.starts(with: url.absoluteString)
    }

    func appendingQueryParameters(_ parameters: [String: String]?) -> URL {
        guard let parameters = parameters,
              var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
                return self
        }
        var mutableQueryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        mutableQueryItems.append(contentsOf: parameters.map { URLQueryItem(name: $0, value: $1) })
        urlComponents.queryItems = mutableQueryItems
        return urlComponents.url!
    }
    
    func valueForQueryParam(withName name: String) -> String? {
        let urlComponents = URLComponents(string: self.absoluteString)
        return urlComponents?.queryItems?.first(where: {$0.name == name})?.value
    }

    static func fromString(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            fatalError("Cannot build url from string: \"\(string)\"")
        }
        return url
    }
}
