import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: MenuModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "Menu", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
