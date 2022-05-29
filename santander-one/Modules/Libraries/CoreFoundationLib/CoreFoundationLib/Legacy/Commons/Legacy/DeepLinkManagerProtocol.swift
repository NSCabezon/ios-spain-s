
public protocol DeepLinkManagerProtocol {
    func isDeepLinkScheduled() -> Bool
    func getScheduledDeepLinkTracker() -> String?
    func registerDeepLink(_ deeplink: DeepLinkEnumerationCapable)
}
