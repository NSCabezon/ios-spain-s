//
//  OtherOperativesCoordinator.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 30/01/2020.
//

import Foundation
import CoreFoundationLib
import UI
import CoreDomain

final class OtherOperativesCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    weak var rootViewController: OtherOperativesViewController?
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    init(resolver: DependenciesResolver, coordinatingViewController controller: UINavigationController?) {
        
        self.dependenciesEngine = DependenciesDefault(father: resolver)
        self.navigationController = controller
        
        self.dependenciesEngine.register(for: GetUserPrefWithoutUserIdUseCase.self) { dependenciesResolver in
            return GetUserPrefWithoutUserIdUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: OtherOperativesPresenterProtocol.self) { dependenciesResolver in
            return OtherOperativesPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: OtherOperativesViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: OtherOperativesViewController.self)
        }
        
        self.dependenciesEngine.register(for: OtherOperativesViewController.self) { [unowned self] dependenciesResolver in
            let presenter: OtherOperativesPresenterProtocol = dependenciesResolver.resolve(for: OtherOperativesPresenterProtocol.self)
            let viewController = OtherOperativesViewController(nibName: "OtherOperativesViewController",
                                                               bundle: Bundle(for: OtherOperativesViewController.self),
                                                               presenter: presenter)
            self.rootViewController = viewController
            viewController.modalPresentationStyle = .fullScreen
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: OtherOperativesCoordinator.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: OtherOperativesWrapper.self) { dependenciesResolver in
            return OtherOperativesWrapper(dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetSearchKeywordsUseCase.self) { dependenciesResolver in
            return GetSearchKeywordsUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
    
    func start() {
        self.navigationController?.present(dependenciesEngine.resolve(for: OtherOperativesViewController.self),
                                           animated: true,
                                           completion: nil)
    }
    
    func dismiss() {
        self.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func goToAction(_ action: Any, _ entity: AllOperatives, _ presentOffers: [PullOfferLocation: OfferEntity]?) {
        self.rootViewController?.dismiss(animated: true) {
            self.dependenciesEngine.resolve(for: GlobalPositionModuleCoordinatorDelegate.self).didSelectAction(action,
                                                                                                               entity,
                                                                                                               presentOffers)
        }
    }
    
    func executeOffer(_ offer: OfferRepresentable) {
        self.rootViewController?.dismiss(animated: true) {
            self.dependenciesEngine.resolve(for: GlobalPositionModuleCoordinatorDelegate.self).didSelectOffer(offer)
        }
    }
    
    func executeDeepLink(_ deepLinkIdentifer: String) {
        guard let deepLink = DeepLink(deepLinkIdentifer) else {
            return
        }
        let deeplinkManager = self.dependenciesEngine.resolve(for: DeepLinkManagerProtocol.self)
        deeplinkManager.registerDeepLink(deepLink)
    }
}
