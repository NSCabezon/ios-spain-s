import CoreFoundationLib
import CoreDomain
import UI
@testable import Menu

class PublicMenuCoordinatorSpy: PublicMenuCoordinator {
    
    var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator]
    var dataBinding: DataBinding
    var openURLCalled: Bool = false
    var goToAtmLocatorCalled: Bool = false
    var goToStockholdersCalled: Bool = false
    var goToOurProductsCalled: Bool = false
    var toggleSideMenuCalled: Bool = false
    var goToHomeTipsCalled: Bool = false
    var goToCustomActionCalled: Bool = false
    var goToComingSoonCalled: Bool = false
    var goToPublicOfferCalled: Bool = false
    
    init() {
        childCoordinators = []
        dataBinding = DataBindingObject()
    }
    
    func start() {
    }
    
    func openUrl(_ url: String) {
        self.openURLCalled = true
    }
    
    func goToAtmLocator() {
        self.goToAtmLocatorCalled = true
    }
    
    func goToStockholders() {
        self.goToStockholdersCalled = true
    }
    
    func goToOurProducts() {
        self.goToOurProductsCalled = true
    }
    
    func toggleSideMenu() {
        self.toggleSideMenuCalled = true
    }
    
    func goToHomeTips() {
        self.goToHomeTipsCalled = true
    }
    
    func goToCustomAction() {
        goToCustomActionCalled = true
    }
    
    func comingSoon() {
        goToComingSoonCalled = true
    }
    
    func goToPublicOffer(offer: OfferRepresentable) {
        goToPublicOfferCalled = true
    }
}
