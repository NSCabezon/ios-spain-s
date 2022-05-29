import Foundation
import CoreFoundationLib
import Menu
import CoreDomain

final class PublicMenuCoordinatorNavigator: ModuleCoordinatorNavigator {
    override var shouldOpenDeepLinkAutomatically: Bool {
        return sessionManager.isSessionActive
    }
}
extension PublicMenuCoordinatorNavigator: PublicMenuCoordinatorDelegate {
    func openUrl(_ url: String) {
        guard let asUrl = URL(string: url), canOpen(asUrl) else { return }
        drawer?.toggleSideMenu()
        open(asUrl)
    }
    
    func goToAtmLocator() {
        drawer?.toggleSideMenu()
        goToATMLocator(keepingNavigation: true)
    }
    
    func goToStockholders() {
        drawer?.toggleSideMenu()
        presentStockholders()
    }
    
    func goToOurProducts() {
        drawer?.toggleSideMenu()
        presentOurProducts()
    }
    
    func goToHomeTips() {
        self.toggleSideMenu()
        presentHomeTips()
    }
    
    func toggleSideMenu() {
        drawer?.toggleSideMenu()
    }
    
    func didSelectOffer(_ offer: OfferRepresentable?) {
        guard let offer = offer else { return }
        drawer?.toggleSideMenu()
        self.executeOffer(offer)
    }
    
    func didSelectOfferNodrawer(_ offer: OfferEntity?) {
        guard let offer = offer else { return }
        self.executeOffer(offer)
    }
    
    func showAlertDialog(
        acceptTitle: LocalizedStylableText,
        cancelTitle: LocalizedStylableText?,
        title: LocalizedStylableText?,
        body: LocalizedStylableText, acceptAction: (() -> Void)?,
        cancelAction: (() -> Void)?) {
        
        guard let viewController = viewController else { return }
        let acceptComponents = DialogButtonComponents(titled: acceptTitle, does: acceptAction)
        var cancelComponents: DialogButtonComponents?
        if let cancelTitle = cancelTitle {
            cancelComponents = DialogButtonComponents(titled: cancelTitle, does: cancelAction)
        }
        Dialog.alert(title: title, body: body, rightButton: acceptComponents, leftButton: cancelComponents, source: viewController, showCloseButton: true)
    }
}

extension PublicMenuCoordinatorNavigator: ATMLocatorNavigatable {
    var customNavigation: NavigationController? {
        return drawer?.currentRootViewController as? NavigationController
    }
}

extension PublicMenuCoordinatorNavigator: UrlActionsCapable {}
extension PublicMenuCoordinatorNavigator: StockholderNavigatable {}
extension PublicMenuCoordinatorNavigator: OurProductsNavigatable {}
extension PublicMenuCoordinatorNavigator: HomeTipsNavigatable {}
