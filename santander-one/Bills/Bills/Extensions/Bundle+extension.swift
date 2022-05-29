import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: BillsModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "Bills", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
