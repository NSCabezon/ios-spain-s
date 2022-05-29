extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: InboxNotificationCoordinator.self)
        let bundleURL = bundle.url(forResource: "InboxNotification", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
