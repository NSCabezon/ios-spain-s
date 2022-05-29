import UIKit
import UI
import CoreFoundationLib

protocol OfferViewNavigatable {
    var presenterProvider: PresenterProvider { get }
    var drawer: BaseMenuViewController { get }
    func goToTutorial(with config: PullOffersTutorialConfiguration)
    func goToCreativity(with config: PullOffersCreativityConfiguration)
    func goToPullOfferDetail(with config: PullOffersDetailConfiguration)
    func goToImageListFullScreen(with config: PullOffersImageListConfiguration)
    func goToFullScreenBanner(with config: PullOfferFullScreenBannerConfiguration)
    func closeAllPullOfferActions()
}

extension OfferViewNavigatable {
    
    func goToFullScreenBanner(with config: PullOfferFullScreenBannerConfiguration) {
        guard let navigator = drawer.currentRootViewController as? NavigationController else { return }
        let fullScreenBannerCoordinator = FullScreenBannerCoordinator(dependenciesResolver: presenterProvider.navigatorProvider.dependenciesEngine, viewController: navigator)
        self.presenterProvider.navigatorProvider.dependenciesEngine.register(for: PullOfferFullScreenBannerConfiguration.self) {_ in
            return config
        }
        self.presenterProvider.dependenciesEngine.register(for: FullScreenBannerCoordinatorDelegate.self) {_ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: PullOffersCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: FloatingBannerCloseDelegate.self) {_ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: GlobalPositionModuleCoordinatorNavigator.self)
        }
        fullScreenBannerCoordinator.start()
    }
    
    func goToTutorial(with config: PullOffersTutorialConfiguration) {
        let tutorialPresenter = presenterProvider.tutorialPresenter(config: config)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.blockingPushViewController(tutorialPresenter.view, animated: true)
    }
    
    func goToCreativity(with config: PullOffersCreativityConfiguration) {
        let presenter = presenterProvider.creativityPresenter(with: config)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.blockingPushViewController(presenter.view, animated: true)
    }
    
    func goToPullOfferDetail(with config: PullOffersDetailConfiguration) {
        let pullOfferDetailPresenter = presenterProvider.pullOfferDetailPresenter(config: config)
        let navigation = drawer.currentRootViewController as? NavigationController
        navigation?.blockingPushViewController(pullOfferDetailPresenter.view, animated: true)
    }
    
    func goToImageListFullScreen(with config: PullOffersImageListConfiguration) {
        let presenter = presenterProvider.imageListFullscreenPresenter(with: config)
        let navigator = drawer.currentRootViewController as? NavigationController
        presenter.view.titleIdentifier = "drawer_custom_title_textview"
        navigator?.blockingPushViewController(presenter.view, animated: true)
    }
    
    func closeAllPullOfferActions() {
        guard let currentRootViewController = drawer.currentRootViewController as? NavigationController, let navigationController = self.presentedNavigationController(from: currentRootViewController) else { return }

        if let viewControllerBeingPresented = currentRootViewController.presentedViewController {
            viewControllerBeingPresented.dismiss(animated: true, completion: nil)
        } else {
            let last = navigationController.viewControllers.last {
                return !($0 is ActionClosableProtocol)
            }
            if let last = last {
                navigationController.popToViewController(last, animated: true)
            } else {
                navigationController.popToRootViewController(animated: true)
            }
        }
    }
    
    func closeAllPullOfferActions(_ completion: (() -> Void)?) {
        guard let currentRootViewController = drawer.currentRootViewController as? NavigationController, let navigationController = self.presentedNavigationController(from: currentRootViewController) else { return }
        closeAllPullOfferActions()
        guard let coordinator = navigationController.transitionCoordinator else {
            DispatchQueue.main.async { completion?() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion?() }
    }
    
    private func presentedNavigationController(from navigationController: UINavigationController) -> UINavigationController? {
        return (navigationController.presentedViewController as? UINavigationController).map(self.presentedNavigationController) ?? navigationController
    }
}
