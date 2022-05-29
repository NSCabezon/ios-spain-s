import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: CoreTestDataForBundle.self)
        let bundleURL = bundle.url(forResource: "CoreTestData", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}

class CoreTestDataForBundle {}
