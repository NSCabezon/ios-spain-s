import UI
import GlobalPosition
import CoreFoundationLib
import Menu

public protocol OnboardingNavigatorProtocol: SystemSettingsNavigatable {
    func dismiss()
    func goBack()
    func next()
    func gotoScene(step: OnboardingStepIdentifier)
    func gpChanged(globalPositionOption: GlobalPositionOption)
    func launchOnboarding(delegate: OnboardingDelegate)
}

final class OnboardingNavigator {
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private var  navigationController: UINavigationController?
    private lazy var onboardingConfiguration: OnboardingConfigurationProtocol = {
        if let countryConfiguration = dependenciesEngine.resolve(forOptionalType: OnboardingConfigurationProtocol.self) {
            return countryConfiguration }
        else {
            return OnboardingConfiguration(dependencies: self.dependenciesEngine)
        }
    }()
    var onboardingCoordinator: OnboardingCoordinator?
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
     }
}

// MARK: - LauncherModuleCoordinator conformance

extension OnboardingNavigator: ModuleLauncher {
    public var dependenciesResolver: DependenciesResolver {
        self.dependenciesEngine
    }
}

extension OnboardingNavigator: ModuleLauncherDelegate {}

extension OnboardingNavigator: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
}

extension OnboardingNavigator: OldDialogViewPresentationCapable {
    public var associatedOldDialogView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
    
    public var associatedGenericErrorDialogView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
}

// MARK: - Onboarding navigation

extension OnboardingNavigator: OnboardingNavigatorProtocol {
    func next() {
        onboardingCoordinator?.next()
    }
    
    func goBack() {
        onboardingCoordinator?.previous()
    }
    
    func gotoScene(step: OnboardingStepIdentifier) {
        onboardingCoordinator?.gotoScene(step: step)
    }

    func gpChanged(globalPositionOption: GlobalPositionOption) {
        let pgCoordinator: GlobalPositionModuleCoordinator = dependenciesEngine.resolve(for: GlobalPositionModuleCoordinator.self)
        dependenciesEngine.register(for: GlobalPositionModuleCoordinatorDelegate.self) { resolver in
            return resolver.resolve(for: NavigatorProvider.self).getModuleCoordinator(type: GlobalPositionModuleCoordinatorNavigator.self)
        }
        dependenciesEngine.register(for: LoanSimulatorOfferDelegate.self) { resolver in
            return resolver.resolve(for: NavigatorProvider.self).getModuleCoordinator(type: GlobalPositionModuleCoordinatorNavigator.self)
        }
        dependenciesEngine.register(for: GetInfoSideMenuUseCaseProtocol.self) { _ in
            return GetInfoSideMenuUseCase(dependenciesResolver: self.dependenciesEngine)
        }
        let navigationController: NavigationController = NavigationController()
        drawer.setRoot(viewController: navigationController)
        pgCoordinator.navigationController = navigationController
        switch globalPositionOption {
        case .classic: pgCoordinator.start(.classic)
        case .simple: pgCoordinator.start(.simple)
        case .smart: pgCoordinator.start(.smart)
        }
        let presenter = dependenciesEngine.resolve(for: NavigatorProvider.self)
        let coordinator = presenter.presenterProvider.navigatorProvider
            .legacyExternalDependenciesResolver
            .privateMenuCoordinator()
        coordinator.start()
        guard let coordinatorNavigator = coordinator.navigationController else { return }
        drawer.setSideMenu(viewController: coordinatorNavigator)
        dependenciesEngine.resolve(for: CoreSessionManager.self).sessionStarted(completion: nil)
    }
    
    func dismiss() {
        guard let navigationController: NavigationController = drawer.currentRootViewController as? NavigationController else { return }
        let last = navigationController.viewControllers.last {
            return !($0 is OnboardingClosableProtocol)
        }
        if let last = last {
            navigationController.popToViewController(last, animated: true)
        } else {
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    func launchOnboarding(delegate: OnboardingDelegate) {
        self.onboardingConfiguration.onboardingDelegate = delegate
        dependenciesEngine.register(for: OnboardingConfigurationProtocol.self) { _ in
            return self.onboardingConfiguration
        }
        guard let navigationController = drawer.currentRootViewController as? NavigationController,
              let globalPositionVC = navigationController.viewControllers.first,
              globalPositionVC is PGViewProtocol else { return }
        let onboardingCoordinator = OnboardingCoordinator(dependenciesResolver: dependenciesEngine,
                                                          navigationController: navigationController)
        self.navigationController = navigationController
        self.onboardingCoordinator = onboardingCoordinator
        onboardingCoordinator.start(withLauncher: self, handleBy: self)
    }
}
