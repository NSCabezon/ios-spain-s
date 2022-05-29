import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: DefaultFeatureFlagsCoordinator.self)
        let bundleURL = bundle.url(forResource: "FeatureFlags", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
