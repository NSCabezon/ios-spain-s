import Operative
import CoreFoundationLib

protocol UpdateSubscriptionFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    var cardExternalDependencies: CardExternalDependenciesResolver { get }
    var navigationController: UINavigationController? { get set }
    var delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol? { get set }
    var dependenciesInjector: DependenciesDefault? { get }
    func goToGlobalPosition()
    func goToCardsHome()
}

extension UpdateSubscriptionFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption = self.getFinishingOption(for: operative) else {
            self.goToLastViewController()
            return
        }
        switch finishingOption {
        case .globalPosition:
            self.goToGlobalPosition()
        case .cardsHome:
            self.goToCardsHome()
        }
    }

    private func getFinishingOption(for operative: Operative) -> UpdateSubscriptionOperative.FinishingOption? {
        guard let operative = operative as? UpdateSubscriptionOperative else { return nil }
        guard let finishingOption: UpdateSubscriptionOperative.FinishingOption = operative.container?.getOptional() else { return nil }
        return finishingOption
    }

    func goToLastViewController() {
        guard let controller = self.navigationController?
                .viewControllers
                .last(where: {
                    $0 is CardSubscriptionsDetailViewController
                        || $0 is CardsSubscriptionsViewController
                        || $0 is CardSubscriptionsViewController
                }) else {
            return self.goToGlobalPosition()
        }
        delegate?.updateSubscriptionSwitch()
        self.navigationController?.popToViewController(controller, animated: true)
    }

    func goToGlobalPosition() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    func goToCardsHome() {
        guard let navigationController = self.navigationController,
              let dependenciesInjector = self.dependenciesInjector else { return }
        
        dependenciesInjector.register(for: CardsHomeConfiguration.self) { _ in
            return CardsHomeConfiguration(selectedCard: nil)
        }
        
        let cardCoordinator = CardsModuleCoordinator(
            dependenciesResolver: dependenciesInjector,
            navigationController: navigationController,
            externalDependencies: cardExternalDependencies
        )
        navigationController.popToRootViewController(animated: false) {
            cardCoordinator.start(.home)
        }
    }
}

final class UpdateSubscriptionFinishingCoordinator {
    weak var navigationController: UINavigationController?
    weak var delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?
    weak var dependenciesInjector: DependenciesDefault?
    let cardExternalDependencies: CardExternalDependenciesResolver
    
    init(navigatorController: UINavigationController?, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?, dependenciesInjector: DependenciesDefault, externalDependencies: CardExternalDependenciesResolver) {
        self.cardExternalDependencies = externalDependencies
        self.navigationController = navigatorController
        self.delegate = delegate
        self.dependenciesInjector = dependenciesInjector
    }
}

extension UpdateSubscriptionFinishingCoordinator: UpdateSubscriptionFinishingCoordinatorProtocol { }
