import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: TransferModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "Transfer", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
