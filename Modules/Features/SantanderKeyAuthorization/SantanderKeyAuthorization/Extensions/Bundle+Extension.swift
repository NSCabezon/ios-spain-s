import Foundation

extension Bundle {

    static let module: Bundle? = {
        let podBundle = Bundle(for: DefaultSKAuthorizationCoordinator.self)
        let bundleURL = podBundle.url(forResource: "SantanderKeyAuthorization", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
