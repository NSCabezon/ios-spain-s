import CoreFoundationLib
import Ecommerce

final class UniversalLinkLauncher {
    private let dependenciesResolver: DependenciesResolver
    private var universalLink: UniversalLink?

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    func launch(_ universalLink: UniversalLink) {
        switch universalLink {
        case .fintech(let userAuthentication):
            self.goToEcommerce(userAuthentication)
        }
        self.cleanAll()
    }
}

private extension UniversalLinkLauncher {
    func cleanAll() {
        self.universalLink = nil
    }
    
    func goToEcommerce(_ userAuthentication: FintechUserAuthenticationKeys) {
        dependenciesResolver
            .resolve(for: EcommerceNavigatorProtocol.self)
            .showEcommerce(.fintechTPPConfirmation(userAuthentication))
    }
}
