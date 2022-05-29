import Foundation
import CoreFoundationLib
import UI

public protocol ApplePayWelcomeCoordinatorDelegate: AnyObject {
    func didSelectApplePay(card: CardEntity?, delegate: ApplePayEnrollmentDelegate)
}

public final class ApplePayWelcomeConfiguration {
    let card: CardEntity?
    weak var applePayEnrollmentDelegate: ApplePayEnrollmentDelegate?
    
    public init(card: CardEntity?, applePayEnrollmentDelegate: ApplePayEnrollmentDelegate) {
        self.card = card
        self.applePayEnrollmentDelegate = applePayEnrollmentDelegate
    }
}

final class ApplePayWelcomeCoordinator: ModuleCoordinator {
    
    weak var navigationController: UINavigationController?
    let dependenciesEngine: DependenciesDefault
    weak var coordinatorDelegate: ApplePayWelcomeCoordinatorDelegate? {
        self.dependenciesEngine.resolve(for: ApplePayWelcomeCoordinatorDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    func start() {
        self.navigationController?.blockingPushViewController(self.dependenciesEngine.resolve(for: ApplePayWelcomeViewController.self), animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func goToApplePay() {
        let configuration = self.dependenciesEngine.resolve(for: ApplePayWelcomeConfiguration.self)
        guard let enrolledDelegate = configuration.applePayEnrollmentDelegate else { return }
        self.dependenciesEngine.register(for: AddToApplePayConfirmationUseCase.self) { dependenciesResolver in
            return AddToApplePayConfirmationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.coordinatorDelegate?.didSelectApplePay(card: configuration.card, delegate: enrolledDelegate)
    }
    
    // MARK: - Private
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: ApplePayWelcomePresenterProtocol.self) { dependenciesResolver in
            return ApplePayWelcomePresenter(dependenciesResolver: dependenciesResolver, coordinator: self)
        }
        self.dependenciesEngine.register(for: ApplePayWelcomeViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: ApplePayWelcomeViewController.self)
        }
        self.dependenciesEngine.register(for: ApplePayWelcomeViewController.self) { dependenciesResolver in
            let presenter: ApplePayWelcomePresenterProtocol = dependenciesResolver.resolve(for: ApplePayWelcomePresenterProtocol.self)
            let viewController = ApplePayWelcomeViewController(nibName: "ApplePayWelcome", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
