import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: InboxModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "Inbox", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
