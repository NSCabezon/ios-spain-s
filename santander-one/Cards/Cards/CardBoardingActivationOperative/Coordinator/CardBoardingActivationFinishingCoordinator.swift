//
//  CardBoardingActivationCoordinator.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 06/10/2020.
//

import Foundation
import CoreFoundationLib
import UI
import Operative

final class CardBoardingActivationFinishingCoordinator {
    private weak var navigationController: UINavigationController?
    private var dependenciesEngine: DependenciesDefault
    private var cardBoardingCoordinator: CardBoardingCoordinator
    private var getUpdatedCard: GetUpdatedCardUseCase {
        return self.dependenciesEngine.resolve(for: GetUpdatedCardUseCase.self)
    }
    private let cardBoardingModifier: CardBoardingModifierProtocol?
    private var useCaseHandler: UseCaseHandler {
        self.dependenciesEngine.resolve(for: UseCaseHandler.self)
    }
    
    init(dependenciesResolver: DependenciesResolver, navigatorController: UINavigationController?, externalDependencies: CardExternalDependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigatorController
        self.cardBoardingCoordinator = CardBoardingCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController, externalDependencies: externalDependencies)
        self.cardBoardingModifier = dependenciesEngine.resolve(forOptionalType: CardBoardingModifierProtocol.self)
    }
}

extension CardBoardingActivationFinishingCoordinator: CardBoardingActivationFinishingCoordinatorProtocol {
    
    func goToCardBoarding(card: CardEntity) {
        self.dependenciesEngine.register(for: CardboardingConfiguration.self) { _ in
            return CardboardingConfiguration(card: card)
        }
        self.dependenciesEngine.register(for: ApplePayEnrollmentManager.self) { resolver in
            return ApplePayEnrollmentManager(dependenciesResolver: resolver)
        }
        self.cardBoardingCoordinator.start(withLauncher: self, handleBy: self)
    }
    
    func goToGlobalPosition() {
        self.navigationController?.enablePopGesture()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func goToCardHome(coordinator: OperativeContainerCoordinatorProtocol) {
        guard let controller = coordinator.sourceView else {
            coordinator.navigationController?.popToRootViewController(animated: true)
            return
        }
        coordinator.navigationController?.popToViewController(controller, animated: true)
    }

    func goToRecoverPin(card: CardEntity, coordinator: OperativeContainerCoordinatorProtocol) {
        guard cardBoardingModifier?.shouldPresentReceivePin() ?? false else { return }
        cardBoardingModifier?.goToReceivePinWebViewWithCard(
            card: card,
            resolver: dependenciesResolver,
            coordinator: coordinator,
            onError: { [weak self] in
                guard let self = self else { return }
                self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
            }
        )
    }
}

extension CardBoardingActivationFinishingCoordinator: ModuleLauncher {
    public var dependenciesResolver: DependenciesResolver {
        self.dependenciesEngine
    }
}

extension CardBoardingActivationFinishingCoordinator: ModuleLauncherDelegate {}

extension CardBoardingActivationFinishingCoordinator: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
}

extension CardBoardingActivationFinishingCoordinator: OldDialogViewPresentationCapable {
    public var associatedOldDialogView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
    
    public var associatedGenericErrorDialogView: UIViewController {
       return self.navigationController?.topViewController ?? UIViewController()
    }
}
