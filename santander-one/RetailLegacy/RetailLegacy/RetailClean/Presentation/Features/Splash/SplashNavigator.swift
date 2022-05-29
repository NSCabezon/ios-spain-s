import Menu
import UIKit
import CoreFoundationLib
import UI
import LoginCommon

protocol AppNavigatorProtocol: ShowingDialogOnCenterViewCapable, BaseWebViewNavigatable {
    func presentApp(from appDelegate: RetailLegacyAppDelegate)
}

class AppNavigator {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension AppNavigator: AppNavigatorProtocol {
    func presentApp(from appDelegate: RetailLegacyAppDelegate) {
        let presenter = presenterProvider.splashPresenter
        presenter.appDelegate = appDelegate
        drawer.setRoot(viewController: presenter.view)
    }
}

class SplashNavigator: PublicNavigatable {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    let legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector, legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
        self.legacyExternalDependenciesResolver = legacyExternalDependenciesResolver
    }
}

protocol PublicNavigatable: MenuNavigator {
    func goToPublic(shouldGoToRememberedLogin: Bool)
    var legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver { get }
}

extension PublicNavigatable {
    
    func goToPublic(shouldGoToRememberedLogin: Bool) {
        UIStyle.setup()
        MiniPlayerView.close()
        if shouldGoToRememberedLogin {
            /*let navigationController = NavigationController(
                rootViewController: presenterProvider.loginRememberedPresenter.view)
            drawer.setRoot(viewController: navigationController)*/
            
            //Uncomment the code above to use the old remembered login
            self.gotoLoginRemembered()
        } else {
             /*let navigationController = NavigationController(
                rootViewController: presenterProvider.loginUnrememberedPresenter.view)
            drawer.setRoot(viewController: navigationController)*/
            
            //Uncomment the code above to use the old unremembered login
            self.gotoUnrememberedLogin()
        }
        drawer.setSideMenu(viewController: UINavigationController())
        
        presenterProvider.dependenciesEngine.register(for: PublicMenuCoordinatorDelegate.self ) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: PublicMenuCoordinatorNavigator.self)
        }
        presenterProvider.dependenciesEngine.register(for: AtmCoordinatorDelegate.self) { _ in
            self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
        }
        let coordinator = legacyExternalDependenciesResolver.publicMenuSceneCoordinator()
        coordinator.start()
        drawer.setSideMenu(viewController: coordinator.navigationController)
    }
}

private extension PublicNavigatable {
    func gotoUnrememberedLogin() {
        self.presenterProvider.dependenciesEngine.register(for: PageTrackable.self) { _ in
            return UnrememberedLoginPage()
        }
        drawer.setRoot(viewController: NavigationController())
        let loginModuleCoordinator = self.presenterProvider.dependenciesEngine.resolve(for: LoginModuleCoordinatorProtocol.self)
        self.presenterProvider.dependenciesEngine.register(for: LoginCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: LoginCoordinatorNavigator.self)
        }
        loginModuleCoordinator.start(.unrememberedLogin)
    }
    
    func gotoLoginRemembered() {
        self.presenterProvider.dependenciesEngine.register(for: PageTrackable.self) { _ in
            return LoginRememberedPage()
        }
        drawer.setRoot(viewController: NavigationController())
        let loginModuleCoordinator = self.presenterProvider.dependenciesEngine.resolve(for: LoginModuleCoordinatorProtocol.self)
        self.presenterProvider.dependenciesEngine.register(for: LoginCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: LoginCoordinatorNavigator.self)
        }
        loginModuleCoordinator.start(.loginRemembered)
    }
}

protocol ModalViewsObserverProtocol {
    var drawer: BaseMenuViewController { get }
    func removeModals()
}

extension ModalViewsObserverProtocol {
    func removeModals() {
        if let currentViewController = drawer.currentRootViewController as? NavigationController {
            currentViewController.dismiss(animated: true, completion: nil)
        }
        self.removeAllTopWindowsViewIfNeeded()
    }

    func removeAllTopWindowsViewIfNeeded() {
        guard let window = UIApplication.shared.windows.first else { return }
        for view in window.subviews where view is TopWindowViewProtocol {
            view.removeFromSuperview()
        }
    }
}

protocol MenuNavigator: BasicNavigator {
    func toggleSideMenu()
    func closeSideMenu()
    
    /// Method to show the logout dialog
    ///
    /// - Parameters:
    ///   - title: The title to show in the dialog
    ///   - acceptText: The text for the accept button
    ///   - cancelText: The text for the cancel button
    ///   - shouldShowOffer: If the dialog should show the offer
    ///   - acceptAction: (Optional) The action for the accept button
    ///   - cancelAction: (Optional) The action for the cancel button
    ///   - offerDidOpenAction: The action associated with the openning of the offer inside the logout dialog
    func showLogoutDialog(acceptAction: @escaping () -> Void, offerDidOpenAction: @escaping () -> Void)
}

extension MenuNavigator {
    func toggleSideMenu() {
        drawer.toggleSideMenu()
    }
    
    func closeSideMenu() {
        drawer.closeSideMenu()
    }
    
    func showLogoutDialog(acceptAction: @escaping () -> Void, offerDidOpenAction: @escaping () -> Void) {
        MiniPlayerView.close()
        let dialogPresenter = presenterProvider.logoutDialog(acceptAction: acceptAction, offerDidOpenAction: offerDidOpenAction)
        dialogPresenter.presentIn(drawer)
    }
}

protocol BasicNavigator {
    var presenterProvider: PresenterProvider { get }
    var drawer: BaseMenuViewController { get }
}
