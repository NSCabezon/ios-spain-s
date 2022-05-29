import UIKit
import GlobalPosition
import CoreFoundationLib
import LoginCommon
import Menu
import CoreDomain
import FeatureFlags

class PublicHomeNavigatorImpl: AppStoreNavigator, PublicHomeNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    let legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector, legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
        self.legacyExternalDependenciesResolver = legacyExternalDependenciesResolver
    }
    
    func goToEnvironmentsSelector(completion: @escaping () -> Void) {
        let presenter = presenterProvider.environmentsSelectorPresenter
        presenter.completion = completion
        presenter.view.modalTransitionStyle = .coverVertical
        presenter.view.modalPresentationStyle = .overCurrentContext
        
        UIViewController.topViewController()?.present(presenter.view, animated: true, completion: nil)
    }
    
    func goToFeatureFlags() {
        let coordinator = DefaultFeatureFlagsCoordinator(dependencies: legacyExternalDependenciesResolver)
        coordinator.start()
    }
    
    func goToURL(source: String) {
        guard let url = URL(string: source), canOpen(url) else {
            return
        }
        open(url)
    }
    
    func goToOtpSca(username: String, isFirstTime: Bool) {
        let presenter: OtpScaLoginPresenter = presenterProvider.otpScaLoginPresenter(username: username, isFirstTime: isFirstTime)
        let navigator: NavigationController? = drawer.currentRootViewController as? NavigationController
        navigator?.setViewControllers([presenter.view], animated: true)
    }
    
    func goToQuickBalance() {
        var loginCoordinatorNavigator: LoginModuleCoordinatorProtocol = dependenciesEngine.resolve(for: LoginModuleCoordinatorProtocol.self)
        dependenciesEngine.register(for: QuickBalanceCoordinatorProtocol.self) { resolver in
            return resolver.resolve(for: NavigatorProvider.self).getModuleCoordinator(type: LoginCoordinatorNavigator.self)
        }
        let navigationController: NavigationController = NavigationController()
        loginCoordinatorNavigator.navigationController = navigationController
        loginCoordinatorNavigator.start(.quickBalance)
    }
}

extension PublicHomeNavigatorImpl {
    var navigationController: NavigationController? {
        return drawer.currentRootViewController as? NavigationController
    }
    
    func goToFakePrivate(_ isPb: Bool, _ name: String?) {
        let fakePgPresenter = presenterProvider.fakeGlobalPositionPresenter
        fakePgPresenter.isPb = isPb
        fakePgPresenter.name = name
        
        if let root = drawer.currentRootViewController as? NavigationController {
            root.pushViewController(fakePgPresenter.view, animated: false)
        }
    }
    
    func backToLogin() {
        if let root = drawer.currentRootViewController as? NavigationController {
            if let fakePg = root.children.last as? FakePGViewController, let presenter = fakePg.presenter {
                presenter.backToLogin()
            }
            root.popToRootViewController(animated: false)
        }
    }
        
    func goToPrivate(globalPositionOption: GlobalPositionOptionEntity) {
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
        let coordinator = self.presenterProvider.navigatorProvider
            .legacyExternalDependenciesResolver
            .privateMenuCoordinator()
        coordinator.start()
        guard let coordinatorNavigator = coordinator.navigationController else { return }
        drawer.setSideMenu(viewController: coordinatorNavigator)
        pgCoordinator.navigationController = navigationController
        switch globalPositionOption {
        case .classic:
            pgCoordinator.start(.classic)
        case .simple:
            pgCoordinator.start(.simple)
        case .smart:
            pgCoordinator.start(.smart)
        }
    }
    
    func reloadSideMenu() {
        let actionsMenuRepository: PublicMenuActionsRepository = legacyExternalDependenciesResolver.resolve()
        actionsMenuRepository.send()
    }
}
