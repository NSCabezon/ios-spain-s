import CoreFoundationLib
import Ecommerce
import RetailLegacy
import ESCommons
import CoreDomain

final class EcommerceCoordinatorNavigator {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension EcommerceCoordinatorNavigator {
    var offerLauncher: OfferCoordinatorLauncher {
        return dependenciesResolver.resolve()
    }
    
    var deepLinkManager: DeepLinkManagerProtocol {
        return dependenciesResolver.resolve()
    }
    
    var opinatorLauncher: OpinatorCoordinatorLauncher {
        return dependenciesResolver.resolve()
    }
}

extension EcommerceCoordinatorNavigator: UrlActionsCapable {}
extension EcommerceCoordinatorNavigator: EcommerceMainModuleCoordinatorDelegate {
    func handleOpinator(_ opinator: OpinatorInfoRepresentable) {
        opinatorLauncher.handleOpinator(opinator)
    }
    
    func openUrl(_ url: String) {
        guard let url = URL(string: url), canOpen(url) else { return }
        open(url)
    }
}

extension EcommerceCoordinatorNavigator: EmptyPurchasesPresenterDelegate {
    func didSelectOffer(_ offer: OfferEntity) {
        offerLauncher.executeOffer(offer)
    }
    
    func registerSecureDeviceDeepLink() {
        deepLinkManager.registerDeepLink(DeepLink.secureDevice)
    }
}
