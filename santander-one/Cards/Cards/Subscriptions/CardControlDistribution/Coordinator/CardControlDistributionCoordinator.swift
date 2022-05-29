import UI
import CoreFoundationLib
import SANLegacyLibrary

protocol CardControlDistributionCoordinatorProtocol {
    func goToCardSubscriptions(_ card: CardEntity?)
    func goToEcommerceCard(_ offer: OfferEntity)
    func dismiss()
    func didSelectMenu()
}

final public class CardControlDistributionCoordinator: ModuleCoordinator {
    public var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let externalDependencies: CardExternalDependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?, externalDependencies: CardExternalDependenciesResolver) {
        self.externalDependencies = externalDependencies
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: CardControlDistributionViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension CardControlDistributionCoordinator: CardControlDistributionCoordinatorProtocol {
    var cardHomeCoordinatorDelegate: CardsHomeModuleCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    func goToCardSubscriptions(_ card: CardEntity?) {
        self.dependenciesEngine.register(for: CardSubscriptionConfiguration.self) { _ in
            return CardSubscriptionConfiguration(card: card)
        }
        let coordinator = CardSubscriptionCoordinator(
            dependenciesResolver: dependenciesEngine,
            navigationController: navigationController ?? UINavigationController(),
            externalDependencies: externalDependencies
        )
        coordinator.start()
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectMenu() {
        self.cardHomeCoordinatorDelegate.didSelectMenu()
    }
    
    func goToEcommerceCard(_ offer: OfferEntity) {
        self.dependenciesEngine.resolve(for: CardsHomeModuleCoordinator.self).didSelectOffer(offer: offer)
    }
}

private extension CardControlDistributionCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: CardControlDistributionCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: CardControlDistributionPresenterProtocol.self) { resolver in
            return CardControlDistributionPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: CardControlDistributionViewController.self) { resolver in
            var presenter = resolver.resolve(for: CardControlDistributionPresenterProtocol.self)
            let viewController = CardControlDistributionViewController(
                dependenciesResolver: resolver,
                presenter: presenter
            )
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: CardControlDistributionViewProtocol.self) { resolver in
            return resolver.resolve(for: CardControlDistributionViewController.self)
        }
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
        guard let navigation = self.navigationController else { return }
        self.dependenciesEngine.register(for: CardsHomeModuleCoordinator.self) { dependenciesResolver in
            return CardsHomeModuleCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: navigation, externalDependencies: self.externalDependencies)
        }
    }
}
