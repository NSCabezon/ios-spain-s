//
//  CardBoardingWelcomeCoordinator.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 12/11/2020.
//

import CoreFoundationLib
import UI
import SANLegacyLibrary
import CoreDomain

protocol CardBoardingWelcomeCoordinatorProtocol {
    func didSelectContinue(card: CardEntity)
    func didSelectClose()
    func didSelectOffer(_ offer: OfferRepresentable)
}

final public class CardBoardingWelcomeCoordinator: ModuleCoordinator {
    
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private var cardBoardingCoordinator: CardBoardingCoordinator
    private var useCaseHandler: UseCaseHandler {
        self.dependenciesEngine.resolve(for: UseCaseHandler.self)
    }
    private let externalDependencies: CardExternalDependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?, externalDependencies: CardExternalDependenciesResolver) {
        self.externalDependencies = externalDependencies
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.cardBoardingCoordinator = CardBoardingCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController, externalDependencies: externalDependencies)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: CardBoardingWelcomeViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private var coordinatorDelegate: CardsHomeModuleCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: CardBoardingWelcomePresenterProtocol.self) { dependenciesResolver in
            return CardBoardingWelcomePresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: CardBoardingWelcomeViewController.self) { dependenciesResolver in
            let presenter: CardBoardingWelcomePresenterProtocol = dependenciesResolver.resolve(for: CardBoardingWelcomePresenterProtocol.self)
            let viewController = CardBoardingWelcomeViewController(nibName: "CardBoardingWelcomeViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: CardBoardingWelcomePresenterProtocol.self) { dependenciesResolver in
            return CardBoardingWelcomePresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: CardBoardingWelcomeUseCase.self) { dependenciesResolver in
            return CardBoardingWelcomeUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: CardBoardingWelcomeCoordinatorProtocol.self) { _ in
            return self
        }
    }
}

extension CardBoardingWelcomeCoordinator: CardBoardingWelcomeCoordinatorProtocol {
    func didSelectOffer(_ offer: OfferRepresentable) {
        self.coordinatorDelegate.didSelectOffer(offer: offer)
    }
    
    func didSelectClose() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func didSelectContinue(card: CardEntity) {
        self.dependenciesEngine.register(for: CardboardingConfiguration.self) { _ in
            return CardboardingConfiguration(card: card)
        }
        self.dependenciesEngine.register(for: ApplePayEnrollmentManager.self) { resolver in
            return ApplePayEnrollmentManager(dependenciesResolver: resolver)
        }
        self.cardBoardingCoordinator.start(withLauncher: self, handleBy: self)
    }
}

extension CardBoardingWelcomeCoordinator: ModuleLauncher {
    public var dependenciesResolver: DependenciesResolver {
        self.dependenciesEngine
    }
}

extension CardBoardingWelcomeCoordinator: ModuleLauncherDelegate {}

extension CardBoardingWelcomeCoordinator: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
}

extension CardBoardingWelcomeCoordinator: OldDialogViewPresentationCapable {
    public var associatedOldDialogView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
    
    public var associatedGenericErrorDialogView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
}
