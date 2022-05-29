import CoreFoundationLib
import Cards

protocol AddToApplePayOperativeLauncher {
    func showAddToApplePay(card: Card?, delegate: OperativeLauncherDelegate)
}

extension AddToApplePayOperativeLauncher {
    func showAddToApplePay(card: Card?, delegate: OperativeLauncherDelegate) {
        let operative = AddToApplePayOperative(dependencies: delegate.dependencies, dependenciesResolver: delegate.dependencies.navigatorProvider.dependenciesEngine)
        let operativeData = AddToApplePayOperativeData(cards: [], card: card)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        
        delegate.dependencies
            .navigatorProvider
            .dependenciesEngine
            .register(for: GetCardApplePaySupportUseCase.self) { resolver in
            return GetCardApplePaySupportUseCase(dependenciesResolver: resolver)
        }
        delegate.dependencies
            .navigatorProvider
            .dependenciesEngine
            .register(for: ApplePayEnrollmentManager.self) { resolver in
            return ApplePayEnrollmentManager(dependenciesResolver: resolver)
        }
        
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: card == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
