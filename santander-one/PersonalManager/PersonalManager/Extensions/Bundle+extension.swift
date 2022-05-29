import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: PersonalManagerModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "PersonalManager", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
