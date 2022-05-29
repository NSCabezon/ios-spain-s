import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: BizumModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "Bizum", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
