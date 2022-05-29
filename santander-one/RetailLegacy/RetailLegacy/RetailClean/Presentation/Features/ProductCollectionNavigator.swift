import UIKit

protocol ProductCollectionNavigatorProtocol: MenuNavigator, UrlActionsCapable {
    func openURL(_ url: URL?)
    func goToPullOfferBanners(_ offers: [Offer], _ categoryId: String)
}

class ProductCollectionNavigator {
    var presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.drawer = drawer
        self.presenterProvider = presenterProvider
    }
}

extension ProductCollectionNavigator: ProductCollectionNavigatorProtocol {
    func goToPullOfferBanners(_ offers: [Offer], _ categoryId: String) {
        let presenter = presenterProvider.pullOfferBannerPresenter(offers: offers, categoryId: categoryId)
        guard let navigationController = drawer.currentRootViewController as? UINavigationController else { return }
        navigationController.pushViewController(presenter.view, animated: true)
    }
    
    func openURL(_ url: URL?) {
        guard let url = url else { return }
        open(url)
    }
}
