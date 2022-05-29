import CoreFoundationLib
import Cards

protocol CardBoardingNavigatorProtocol {
    func gotoWelcomeWithCard(_ card: CardEntity)
    func gotoActivateCard(_ card: CardEntity)
    func gotoCardsSelectionHome(cards: [CardEntity])
}

public final class CardBoardingNavigator {
    private var presenterProvider: PresenterProvider
    private var drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver
    private var navigationController: UINavigationController {
        self.drawer.currentRootViewController as? UINavigationController ?? UINavigationController()
    }
    private var cardHomeNavigator: CardsHomeCoordinatorNavigator {
        self.presenterProvider.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
    }
    private let externalDependencies: CardExternalDependenciesResolver
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver) {
        self.presenterProvider = presenterProvider
        self.dependenciesEngine = dependenciesEngine
        self.drawer = drawer
        self.externalDependencies = presenterProvider.navigatorProvider.cardExternalDependenciesResolver
        self.setupDependencies()
    }
    
    func gotoWelcomeWithCard(_ card: CardEntity) {
        self.presenterProvider.dependenciesEngine.register(for: CardboardingConfiguration.self) { _ in
                return CardboardingConfiguration(card: card)
        }
        let coordinator = CardBoardingWelcomeCoordinator(dependenciesResolver: self.dependenciesEngine,
                                                         navigationController: self.navigationController,
                                                         externalDependencies: externalDependencies)
        coordinator.start()
    }
    
    func gotoActivateCard(_ card: CardEntity) {
        self.cardHomeNavigator.goToCardBoardingActivation(card: card)
    }
    
    func gotoCardsSelectionHome(cards: [CardEntity]) {
        let cardsSelectorConfiguration = CardBoardingCardsSelectorConfiguration(cards: cards)
        self.presenterProvider.dependenciesEngine.register(for: CardBoardingCardsSelectorConfiguration.self) { _ in
            return cardsSelectorConfiguration
        }
        let coordinator = CardBoardingCardsSelectorCoordinator(dependenciesResolver: self.presenterProvider.dependenciesEngine, navigationController: self.navigationController)
        coordinator.start()
    }
}

// MARK: - CardBoardingNavigatorProtocol CardBoardingCardsSelectorCoordinatorDelegate
extension CardBoardingNavigator: CardBoardingNavigatorProtocol, CardBoardingCardsSelectorCoordinatorDelegate {
    public func didSelectCard(_ card: CardEntity) {
        if card.isInactive {
            self.gotoActivateCard(card)
        } else {
            self.gotoWelcomeWithCard(card)
        }
    }
}

// MARK: - Private extensions
private extension CardBoardingNavigator {
    func setupDependencies() {
        self.presenterProvider.dependenciesEngine.register(for: CardBoardingCardsSelectorCoordinatorDelegate.self) { _ in
            return self
        }
        self.presenterProvider
            .dependenciesEngine.register(for: CardsHomeModuleCoordinatorDelegate.self) { _ in
                self.cardHomeNavigator
            }

        self.presenterProvider.dependenciesEngine.register(for: CardBoardingCoordinatorDelegate.self) { _ in
            self.cardHomeNavigator
        }
    }
}
