//
//  ComingFeaturesCoordinator.swift
//  Pods
//
//  Created by Cristobal Ramos Laina on 19/02/2020.
//

import Foundation
import CoreFoundationLib
import UI
import CoreDomain

public protocol ComingFeaturesCoordinatorDelegate: AnyObject {
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didSelectTryFeatures()
    func didSelectNewFeature(withOpinator opinator: OpinatorInfoRepresentable)
    func didSelectOffer(_ offer: OfferRepresentable?)
}

final class ComingFeaturesCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: ComingFeaturesViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: VoteComingFeatureUseCase.self) { dependenciesResolver in
            return VoteComingFeatureUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: ComingFeaturesPresenterProtocol.self) { dependenciesResolver in
            return ComingFeaturesPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: ComingFeaturesViewController.self) { dependenciesResolver in
            let presenter: ComingFeaturesPresenterProtocol = dependenciesResolver.resolve(for: ComingFeaturesPresenterProtocol.self)
            let viewController = ComingFeaturesViewController(nibName: "ComingFeaturesViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: GetPullOffersIdUseCase.self) { dependenciesResolver in
            return GetPullOffersIdUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetAllComingFeaturesUseCase.self) { dependenciesResolver in
            return GetAllComingFeaturesUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: VoteComingFeatureUseCase.self) { dependenciesResolver in
            return VoteComingFeatureUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}
