import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: OnboardingBundle.self)
        let bundleURL = bundle.url(forResource: "Onboarding", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}

class OnboardingBundle {
    
}
