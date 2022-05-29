import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: LoginModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "Login", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
