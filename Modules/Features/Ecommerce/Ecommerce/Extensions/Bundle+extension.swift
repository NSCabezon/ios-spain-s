import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: EcommerceModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "Ecommerce", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
