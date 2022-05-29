extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: PrivateMenuViewController.self)
        let bundleURL = bundle.url(forResource: "PrivateMenu", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
