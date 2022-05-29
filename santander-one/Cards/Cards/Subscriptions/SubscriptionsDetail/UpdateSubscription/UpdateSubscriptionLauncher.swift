import Operative
import CoreFoundationLib

protocol UpdateSubscriptionLauncher: OperativeContainerLauncher {
    var cardExternalDependencies: CardExternalDependenciesResolver { get }
    func showActivateSubscription(handler: OperativeLauncherHandler, card: CardEntity, subscription: CardSubscriptionEntityRepresentable, subscriptionIsOn: Bool, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?)
}

extension UpdateSubscriptionLauncher {
    func showActivateSubscription(handler: OperativeLauncherHandler, card: CardEntity, subscription: CardSubscriptionEntityRepresentable, subscriptionIsOn: Bool, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        let operative = UpdateSubscriptionOperative(dependencies: dependenciesEngine, isActivation: subscriptionIsOn)
        let operativeData = UpdateSubscriptionOperativeData(card, subscription: subscription)
        self.setupDependencies(in: dependenciesEngine, handler: handler, delegate: delegate)
        self.go(to: operative, handler: handler, operativeData: operativeData)
    }

    private func setupDependencies(in dependenciesInjector: DependenciesDefault, handler: OperativeLauncherHandler, delegate: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol?) {
        dependenciesInjector.register(for: UpdateSubscriptionFinishingCoordinatorProtocol.self) { _ in
            return UpdateSubscriptionFinishingCoordinator(navigatorController: handler.operativeNavigationController, delegate: delegate, dependenciesInjector: dependenciesInjector, externalDependencies: cardExternalDependencies)
        }
    }
}
