import CoreDomain

public struct OpenAppAction: OfferActionRepresentable {
    public let appUrlScheme: String
    public let storeAppId: Int
    public let fallbackStore: Bool
    public let enableSso: Bool
    public let type = "open_app"
    
    public init(appUrlScheme: String?, iosStoreAppId: String?, fallbackStore: Bool?, enableSso: Bool?) {
        self.appUrlScheme = appUrlScheme ?? ""
        self.storeAppId = Int(iosStoreAppId ?? "") ?? 0
        self.fallbackStore = fallbackStore ?? false
        self.enableSso = enableSso ?? false
    }
    
    public func getDeserialized() -> String {
        return "<app_url_scheme><![CDATA[\(appUrlScheme)]]></app_url_scheme><ios_store_app_id><![CDATA[\(storeAppId)]]></ios_store_app_id><fallback_store>\(fallbackStore)</fallback_store><enable_sso>\(enableSso)</enable_sso>"
    }
}
