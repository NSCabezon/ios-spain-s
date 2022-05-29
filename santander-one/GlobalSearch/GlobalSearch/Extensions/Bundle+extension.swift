import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: GlobalSearchModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "GlobalSearch", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
