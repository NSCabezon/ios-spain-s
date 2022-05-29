import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: SendMoneyOperative.self)
        let bundleURL = bundle.url(forResource: "TransferOperatives", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
