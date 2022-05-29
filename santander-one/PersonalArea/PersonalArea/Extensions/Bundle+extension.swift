import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: PersonalAreaModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "PersonalArea", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
