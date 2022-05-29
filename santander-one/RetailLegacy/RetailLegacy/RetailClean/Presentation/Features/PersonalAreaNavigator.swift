import UIKit
import GlobalPosition
import CoreFoundationLib
import Menu

protocol PersonalAreaNavigatorProtocol: MenuNavigator, OperativesNavigatorProtocol, SystemSettingsNavigatable, PublicNavigatable {
    func navigateToCustomizeApp()
    func navigateToCustomizeAvatar()
    func navigateToVisualOptions()
    func goToAppInfo(appInfo: AppInfoDO)
    func goToPrivate(globalPositionOption: GlobalPositionOptionEntity)
    func goToFakePrivate(_ isPb: Bool, _ name: String?)
    func returnToGlobalPosition()
    func navigateToFrequentOperatives()
    func navigateToPermissions()
    func goToOtpPushInfo(device: OTPPushDevice)
}

class PersonalAreaNavigator: AppStoreNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    var legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector, legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
        self.legacyExternalDependenciesResolver = legacyExternalDependenciesResolver
        super.init()
    }
}

extension PersonalAreaNavigator: PersonalAreaNavigatorProtocol {
    func navigateToPermissions() {
        guard let navigation = drawer.currentRootViewController as? NavigationController else { return }
        let visualOptions = presenterProvider.permissionsPresenter
        navigation.pushViewController(visualOptions.view, animated: true)
    }
    
    func navigateToCustomizeApp() {
        guard let navigation = drawer.currentRootViewController as? NavigationController else { return }
        let customizeApp = presenterProvider.customizeAppPresenter
        navigation.pushViewController(customizeApp.view, animated: true)
    }
    
    func navigateToCustomizeAvatar() {
        guard let navigation = drawer.currentRootViewController as? NavigationController else { return }
        let customizeApp = presenterProvider.customizeAvatarPresenter
        navigation.pushViewController(customizeApp.view, animated: true)
    }
    
    func navigateToVisualOptions() {
        guard let navigation = drawer.currentRootViewController as? NavigationController else { return }
        let visualOptions = presenterProvider.visualOptionsPresenter
        navigation.pushViewController(visualOptions.view, animated: true)
    }
    
    func goToAppInfo(appInfo: AppInfoDO) {
        let presenter = presenterProvider.appInfoPresenter(appInfo: appInfo)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
    
    func navigateToFrequentOperatives() {
        let presenter = presenterProvider.personalAreaFrequentOperativesPresenter()
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }

    func goToFakePrivate(_ isPb: Bool, _ name: String?) {
        let fakePgPresenter = presenterProvider.fakeGlobalPositionPresenter
        fakePgPresenter.isPb = isPb
        fakePgPresenter.name = name
        
        if let root = drawer.currentRootViewController as? NavigationController {
            root.pushViewController(fakePgPresenter.view, animated: false)
        }
    }
    
    func returnToGlobalPosition() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        navigationController?.popToRootViewController(animated: true)
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
        let navigationController: NavigationController = NavigationController()
        drawer.setRoot(viewController: navigationController)
        pgCoordinator.navigationController = navigationController
        switch globalPositionOption {
        case .classic: pgCoordinator.start(.classic)
        case .simple: pgCoordinator.start(.simple)
        case .smart: pgCoordinator.start(.smart)
        }
        let coordinator = self.presenterProvider.navigatorProvider
            .legacyExternalDependenciesResolver
            .privateMenuCoordinator()
        coordinator.start()
        guard let coordinatorNavigator = coordinator.navigationController else { return }
        drawer.setSideMenu(viewController: coordinatorNavigator)
    }
    
    func goToOtpPushInfo(device: OTPPushDevice) {
        let presenter = presenterProvider.otpPushInfoPresenter(device: device)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
}

extension PersonalAreaNavigator: PullOffersActionsNavigatorProtocol {}

extension PersonalAreaNavigator: PublicNavigatable {}
