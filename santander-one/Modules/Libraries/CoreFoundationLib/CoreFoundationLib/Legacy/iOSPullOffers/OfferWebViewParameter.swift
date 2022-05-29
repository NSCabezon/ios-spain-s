public struct OfferWebViewParameter {
    
    public let key: String
    public let value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public protocol WebViewMacroCapable {
    var key: String { get }
    var value: String { get }
}

extension OfferWebViewParameter: WebViewMacroCapable {}
