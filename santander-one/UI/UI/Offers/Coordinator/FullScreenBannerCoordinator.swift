//
//  FullScreenBannerCoordinator.swift
//  UI
//
//  Created by Cristobal Ramos Laina on 24/04/2020.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public protocol FullScreenBannerCoordinatorDelegate: AnyObject {
    func executeOffer(offerAction: OfferActionRepresentable)
}

protocol FullScreenBannerCoordinatorProtocol {
    func dismiss(completion: (() -> Void)?)
    func execute(offerAction: OfferActionRepresentable)
}

public class FullScreenBannerCoordinator {
    
    weak var viewController: UIViewController?
    let dependenciesEngine: DependenciesDefault
    var offer: PullOfferFullScreenBannerConfiguration?
    
    public init(dependenciesResolver: DependenciesResolver, viewController: UIViewController) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.viewController = viewController
        self.setupDependencies()
    }
    var coordinatorDelegate: FullScreenBannerCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: FullScreenBannerCoordinatorDelegate.self)
    }
    
    public func start() {
        let dialogViewController = self.dependenciesEngine.resolve(for: FullScreenBannerViewController.self)
        dialogViewController.modalPresentationStyle = .overCurrentContext
        dialogViewController.modalTransitionStyle = .crossDissolve
        self.viewController?.present(dialogViewController, animated: true, completion: nil)
    }
}

private extension FullScreenBannerCoordinator {
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: FullScreenBannerPresenterProtocol.self) { resolver in
            return FullScreenBannerPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: FullScreenBannerViewController.self) { resolver in
            let presenter: FullScreenBannerPresenterProtocol = resolver.resolve()
            let viewController = FullScreenBannerViewController(nibName: "FullScreenBannerViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: FullScreenBannerCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: ExpirePullOfferUseCase.self) { dependenciesResolver in
            return ExpirePullOfferUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}

extension FullScreenBannerCoordinator: FullScreenBannerCoordinatorProtocol {
    func execute(offerAction: OfferActionRepresentable) {
        coordinatorDelegate.executeOffer(offerAction: offerAction)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.viewController?.presentedViewController?.dismiss(animated: true, completion: completion)
    }
}
