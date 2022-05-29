import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: XibButton.self)
        let bundleURL = bundle.url(forResource: "UIOneComponents", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
