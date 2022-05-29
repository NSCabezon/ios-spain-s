import UIKit
import Cards
import CoreFoundationLib

protocol ApplePayNavigatorProtocol: MenuNavigator {
    func goToAddToApplePay()
}

class ApplePayNavigator {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
    }
}

extension ApplePayNavigator: ApplePayNavigatorProtocol {
    func goToAddToApplePay() {
        self.dependenciesEngine.register(for: ApplePayWelcomeCoordinatorDelegate.self) { _ in
            self.presenterProvider.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        self.dependenciesEngine.register(for: ApplePayEnrollmentDelegate.self) {_ in
            self.presenterProvider.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        self.dependenciesEngine.register(for: ApplePayWelcomeConfiguration.self) { resolver in
            let delegate = resolver.resolve(for: ApplePayEnrollmentDelegate.self)
            return ApplePayWelcomeConfiguration(card: nil, applePayEnrollmentDelegate: delegate)
        }
        self.presenterProvider.navigatorProvider.productsNavigator.showCardsHome(with: nil, cardSection: .applePay)
    }
}
