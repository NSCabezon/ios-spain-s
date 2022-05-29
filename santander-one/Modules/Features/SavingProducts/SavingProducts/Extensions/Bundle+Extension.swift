import Foundation

extension Bundle {
    
    static let module: Bundle? = {
        let podBundle = Bundle(for: DefaultSavingsHomeCoordinator.self)
        let bundleURL = podBundle.url(forResource: "SavingProducts", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
