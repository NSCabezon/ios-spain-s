//
//  CardBoardingCoordinator.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/5/20.
//

import Foundation
import CoreFoundationLib
import UI
import CoreDomain

public protocol CardBoardingCoordinatorDelegate: AnyObject, LocationPermissionSettingsProtocol {
    func didSelectOffer(offer: OfferRepresentable)
    func handleOpinator(_ opinator: OpinatorInfoRepresentable)
    func didSelectAddToApplePay(card: CardEntity?, delegate: ApplePayEnrollmentDelegate)
    func openSettings()
}

protocol CardBoardingCoordinatorProtocol {
    func didSelectGoBackwards()
    func didSelectGoFoward()
    func didSelectGoToMyCards(card: CardEntity)
    func didSelectGoToGlobalPosition()
    func reloadGlobalPosition()
}

public final class CardBoardingCoordinator: LauncherModuleCoordinator {
    public  var navigationController: UINavigationController?
    private var dependenciesEngine: DependenciesDefault
    private var quitPopupDialog: QuitPopupDialog
    private lazy var builder: CardBoardingStepBuilder = {
        return CardBoardingStepBuilder(dependenciesResolver: dependenciesEngine)
    }()
    private lazy var stepInteractor: StepInteractor = {
        return StepInteractor(steps: builder.build())
    }()
    private lazy var proxy: CardboardingProxy = {
        return self.dependenciesEngine.resolve(for: CardboardingProxy.self)
    }()
    private lazy var cardBoardingStepTracker: CardBoardingStepTracker = {
        let config = self.dependenciesEngine.resolve(for: CardboardingConfiguration.self)
        return CardBoardingStepTracker(card: config.selectedCard, paymentMethod: config.paymentMethod?.paymentMethodCategory)
    }()
    private let externalDependencies: CardExternalDependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?, externalDependencies: CardExternalDependenciesResolver) {
        self.externalDependencies = externalDependencies
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.quitPopupDialog = QuitPopupDialog()
        self.setup()
    }
    
    public func start(withLauncher launcher: ModuleLauncher, handleBy delegate: ModuleLauncherDelegate) {
        launcher.enableLoading(enable: true, handledBy: delegate)
            .does(proxy: self.proxy, handleBy: delegate) { [weak self] configuration in
                self?.dependenciesEngine.register(for: CardboardingConfiguration.self) { _ in
                    return configuration
                }
                self?.cardboardingBegins()
        }
    }
}

private extension CardBoardingCoordinator {
    func cardboardingBegins() {
        self.stepInteractor.resetCurrentPosition()
        guard let step = self.stepInteractor.next() else { return }
        guard let stepViewController = step.view as? UIViewController else { return }
        self.navigationController?.pushViewController(stepViewController, animated: true)
        self.navigationController?.dismissOperative()
        self.navigationController?.disablePopGesture()
        guard step.showTopBarItems() else { return }
        self.addStepNavigationItems()
    }
    
    func setup() {
        self.quitPopupDialog.setDelegate(self)
        self.setupPreLaunchDependencies()
    }
    
    func setupPreLaunchDependencies() {
        self.dependenciesEngine.register(for: CardBoardingStepTracker.self) {_ in
            return self.cardBoardingStepTracker
        }
        self.dependenciesEngine.register(for: CardBoardingCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: GetUpdatedCardUseCase.self) { resolver in
            return GetUpdatedCardUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: CardboardingConfigurationUseCase.self) { resolver in
            return CardboardingConfigurationUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetCardApplePaySupportUseCase.self) { resolver in
            return GetCardApplePaySupportUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: CardboardingProxy.self) { resolver in
            return CardboardingProxy(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: CardboardingPreSetupSuperUseCase.self) { resolver in
            return CardboardingPreSetupSuperUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetCreditCardPaymentMethodUseCase.self) { resolver in
            return GetCreditCardPaymentMethodUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LocationPermission.self) { resolver in
            return LocationPermission(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LocationPermissionSettingsProtocol.self) { _ in
            return self.dependenciesEngine.resolve(for: CardBoardingCoordinatorDelegate.self)
        }
    }
    
    func addStepNavigationItems() {
        let currentPosition = stepInteractor.getCurrentPosition()
        let total = stepInteractor.count - 1
        self.navigationController?.addStepIndicatorBar(currentPosition: currentPosition + 1, total: total)
        self.navigationController?.addCloseButtonItem(target: self, selector: #selector(didSelectClose))
    }
}

extension CardBoardingCoordinator: CardBoardingCoordinatorProtocol {
    @objc func didSelectClose() {
        guard let view = self.navigationController?.view else { return }
        view.endEditing(true)
        self.quitPopupDialog.show(over: view)
    }
    
    func didSelectGoBackwards() {
        self.stepInteractor.popStep()
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectGoFoward() {
        guard let step = self.stepInteractor.next() else { return }
        guard let stepViewController = step.view as? UIViewController else { return }
        self.navigationController?.pushViewController(stepViewController, animated: true)
        guard step.showTopBarItems() else { return }
        self.addStepNavigationItems()
    }
    
    func didSelectGoToMyCards(card: CardEntity) {
        guard let navigation = self.navigationController else { return }
        let cardCoordinator = CardsHomeModuleCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: navigation, externalDependencies: externalDependencies)
        self.dependenciesEngine.register(for: CardsHomeConfiguration.self) { _ in
            return CardsHomeConfiguration(selectedCard: card)
        }
        self.navigationController?.popToRootViewController(animated: false) { [weak self] in
            cardCoordinator.start(animated: false)
            self?.reloadGlobalPosition()
        }
    }
    
    func didSelectGoToGlobalPosition() {
        self.navigationController?.enablePopGesture()
        self.navigationController?.popToRootViewController(animated: true)
        self.reloadGlobalPosition()
    }
    
    func reloadGlobalPosition() {
        let globalPositionReloader = self.dependenciesEngine.resolve(for: GlobalPositionReloader.self)
        globalPositionReloader.reloadGlobalPosition()
    }
}

extension CardBoardingCoordinator: QuitPopupDialogDelegate {
    func didSelectQuit() {
        self.navigationController?.dismissCardboarding()
        self.reloadGlobalPosition()
    }
    
    func didSelectResume() {
        self.quitPopupDialog.resume()
    }
}
