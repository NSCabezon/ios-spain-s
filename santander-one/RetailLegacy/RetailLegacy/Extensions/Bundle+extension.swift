import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: RetailLegacyModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "RetailLegacy", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
