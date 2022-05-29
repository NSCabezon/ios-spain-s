//
//  CardSubscriptionCoordinator.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 24/02/2021.
//

import UI
import CoreFoundationLib
import Operative

public protocol CardSubscriptionCoordinatorCoordinatorDelegate: AnyObject {}

protocol CardSubscriptionCoordinatorProtocol {
    func showMenu()
    func didSelectDismiss()
    func gotoCardsHome()
    func goToSubscriptionDetail(_ viewModel: CardSubscriptionViewModel, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?)
    func gotoCardEasyPayOperative(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?)
    func showActivateSubscription(_ card: CardEntity, subscription: CardSubscriptionEntityRepresentable, subscriptionIsOn: Bool, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?)
}

final public class CardSubscriptionCoordinator: ModuleCoordinator {
    public var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    let cardExternalDependencies: CardExternalDependenciesResolver
    var coordinatorDelegate: CardSubscriptionCoordinatorCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: CardSubscriptionCoordinatorCoordinatorDelegate.self)
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?, externalDependencies: CardExternalDependenciesResolver) {
        self.cardExternalDependencies = externalDependencies
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        guard let controller = self.dependenciesEngine.resolve(for: CardSubscriptionGlobalViewProtocol.self) as? UIViewController
        else { return }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

private extension CardSubscriptionCoordinator {
    var cardHomeCoordinatorDelegate: CardsHomeModuleCoordinatorDelegate {
        self.dependenciesEngine.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    func setupDependencies() {
        dependenciesEngine.register(for: CardSubscriptionPresenterProtocol.self) { resolver in
            return CardSubscriptionPresenter(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: CardSubscriptionCoordinatorProtocol.self) { _ in
            return self
        }
        dependenciesEngine.register(for: GetSubscriptionsListUseCase.self) { resolver in
            return GetSubscriptionsListUseCase(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: IsM4MactiveSuscriptionEnabledUseCaseAlias.self) { resolver in
            return IsM4MactiveSuscriptionEnabledUseCase(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: GetMerchantUseCase.self) { resolver in
            return GetMerchantUseCase(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: GetCardTransactionEasyPaySuperUseCase.self) { resolver in
            return GetCardTransactionEasyPaySuperUseCase(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: GetCardEasyPayOperativeDataUseCase.self) { resolver in
            return GetCardEasyPayOperativeDataUseCase(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: FirstFeeInfoEasyPayUseCase.self) { resolver in
            return FirstFeeInfoEasyPayUseCase(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: CardSubscriptionGlobalViewProtocol.self) { dependenciesResolver in
            let configuration: CardSubscriptionConfiguration = dependenciesResolver.resolve()
            let presenter: CardSubscriptionPresenterProtocol = dependenciesResolver.resolve(for: CardSubscriptionPresenterProtocol.self)
            let viewController = self.viewForPresenter(presenter,
                                                       withCard: configuration.selectedCard != nil)
            presenter.view = viewController
            return viewController
        }
    }
    
    func viewForPresenter(_ presenter: CardSubscriptionPresenterProtocol, withCard: Bool) -> CardSubscriptionGlobalViewProtocol {
        if withCard {
            return CardSubscriptionsViewController(nibName: "CardSubscriptionsViewController",
                                                  bundle: Bundle.module,
                                                  presenter: presenter)
        } else {
            return CardsSubscriptionsViewController(nibName: "CardsSubscriptionsViewController",
                                                                bundle: Bundle.module,
                                                                presenter: presenter)
        }
    }
}

extension CardSubscriptionCoordinator: CardSubscriptionCoordinatorProtocol {
    func gotoCardsHome() {
        guard let optionalNavigationController = self.navigationController else { return }
        self.dependenciesEngine.register(for: CardsHomeConfiguration.self) { _ in
            return CardsHomeConfiguration(selectedCard: nil)
        }
        let cardCoordinator = CardsModuleCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: optionalNavigationController,
            externalDependencies: cardExternalDependencies
        )
        optionalNavigationController.popToRootViewController(animated: false) {
            cardCoordinator.start(.home)
        }
    }
    
    func showMenu() {
        self.cardHomeCoordinatorDelegate.didSelectMenu()
    }
    
    public func didSelectDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func goToSubscriptionDetail(_ viewModel: CardSubscriptionViewModel, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?) {
        let coordinatorDetail = CardSubscriptionDetailCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: self.navigationController, delegate: delegate, externalDependencies: cardExternalDependencies)
        dependenciesEngine.register(for: CardSubscriptionDetailConfiguration.self) { _ in
            return CardSubscriptionDetailConfiguration(detailViewModel: viewModel)
        }
        coordinatorDetail.start()
    }
    
    func gotoCardEasyPayOperative(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?) {
        cardHomeCoordinatorDelegate.easyPay(entity: card, transactionEntity: transaction, easyPayOperativeDataEntity: easyPayOperativeData)
    }
    
    func showActivateSubscription(_ card: CardEntity, subscription: CardSubscriptionEntityRepresentable, subscriptionIsOn: Bool, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?) {
        let coordinatorDetail = CardSubscriptionDetailCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: self.navigationController, delegate: delegate, externalDependencies: cardExternalDependencies)
        coordinatorDetail.showActivateSubscription(handler: self, card: card, subscription: subscription, subscriptionIsOn: subscriptionIsOn, delegate: delegate)
    }
}

extension CardSubscriptionCoordinator: UpdateSubscriptionLauncher {}

extension CardSubscriptionCoordinator: OperativeLauncherHandler {
    public var operativeNavigationController: UINavigationController? {
        return self.navigationController
    }

    public var dependenciesResolver: DependenciesResolver {
        return self.dependenciesEngine
    }

    public func showOperativeLoading(completion: @escaping () -> Void) {
        self.showLoading(completion: completion)
    }

    public func hideOperativeLoading(completion: @escaping () -> Void) {
        self.dismissLoading(completion: completion)
    }

    public func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        let delegate = self.dependenciesEngine.resolve(for: CardsHomeModuleCoordinatorDelegate.self)

        guard let navigationController = self.navigationController else {
            return
        }
        guard let titleString = keyTitle,
              let descriptionString = keyDesc else {
            return
        }
        delegate.showDialog(acceptTitle: localized("generic_button_accept"),
                            cancelTitle: nil,
                            title: localized(titleString),
                            body: localized(descriptionString),
                            showsCloseButton: true,
                            source: navigationController,
                            acceptAction: nil,
                            cancelAction: nil)
        completion?()
    }
}

extension CardSubscriptionCoordinator: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        self.navigationController?.topViewController ?? UIViewController()
    }
}
