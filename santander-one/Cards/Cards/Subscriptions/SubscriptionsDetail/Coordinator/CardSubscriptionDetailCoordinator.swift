//
//  CardSubscriptionDetailCoordinator.swift
//  Cards
//
//  Created by Ignacio González Miró on 7/4/21.
//

import UI
import CoreFoundationLib
import Operative

protocol CardSubscriptionDetailCoordinatorDelegate: AnyObject {
    var delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol? { get set }
    func dismiss()
    func gotoCardEasyPayOperative(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?)
    func showActivateSubscription(card: CardEntity, subscription: CardSubscriptionEntityRepresentable, subscriptionIsOn: Bool, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?)
}

final public class CardSubscriptionDetailCoordinator: ModuleCoordinator {
    public var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    weak var delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?
    let cardExternalDependencies: CardExternalDependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?, externalDependencies: CardExternalDependenciesResolver) {
        self.cardExternalDependencies = externalDependencies
        self.delegate = delegate
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: CardSubscriptionsDetailViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

private extension CardSubscriptionDetailCoordinator {
    var cardHomeCoordinatorDelegate: CardsHomeModuleCoordinatorDelegate {
        self.dependenciesEngine.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    func setupDependencies() {
        dependenciesEngine.register(for: CardSubscriptionsDetailViewController.self) { resolver in
            var presenter = self.dependenciesEngine.resolve(for: CardSubscriptionsDetailPresenterProtocol.self)
            let viewController = CardSubscriptionsDetailViewController(dependenciesResolver: resolver, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        dependenciesEngine.register(for: CardSubscriptionsDetailViewProtocol.self) { resolver in
            return resolver.resolve(for: CardSubscriptionsDetailViewController.self)
        }
        dependenciesEngine.register(for: CardSubscriptionsDetailPresenterProtocol.self) { resolver in
            return CardSubscriptionsDetailPresenter(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: CardSubscriptionDetailCoordinatorDelegate.self) { _ in
            return self
        }
        dependenciesEngine.register(for: GetSubscriptionGraphDataUseCase.self) { resolver in
            return GetSubscriptionGraphDataUseCase(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: GetSubscriptionHistoricalUseCase.self) { resolver in
            return GetSubscriptionHistoricalUseCase(dependenciesResolver: resolver)
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
    }
}

extension CardSubscriptionDetailCoordinator: CardSubscriptionDetailCoordinatorDelegate {
    public func dismiss() {
        delegate?.updateSubscriptionSwitch()
        self.navigationController?.popViewController(animated: true)
    }
    
    public func gotoCardEasyPayOperative(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?) {
        cardHomeCoordinatorDelegate.easyPay(entity: card, transactionEntity: transaction, easyPayOperativeDataEntity: easyPayOperativeData)
    }

    func showActivateSubscription(card: CardEntity, subscription: CardSubscriptionEntityRepresentable, subscriptionIsOn: Bool, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?) {
        self.showActivateSubscription(handler: self, card: card, subscription: subscription, subscriptionIsOn: subscriptionIsOn, delegate: delegate)
    }
}

extension CardSubscriptionDetailCoordinator: UpdateSubscriptionLauncher {}

extension CardSubscriptionDetailCoordinator: OperativeLauncherHandler {
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

extension CardSubscriptionDetailCoordinator: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        self.navigationController?.topViewController ?? UIViewController()
    }
}
