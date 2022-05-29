//
//  AtmCoordinator.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 31/08/2020.
//

import CoreFoundationLib
import UI
import SANLegacyLibrary
import CoreDomain

public protocol AtmCoordinatorDelegate: AnyObject {
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didSelectedGetMoneyWithCode()
    func didSelectedCardLimitManagement()
    func didSelectOffer(_ offer: OfferRepresentable?)
    func didSelectSearchAtm()
    func goToHomeTips()
}

protocol AtmCoordinatorProtocol {
}

final class DefaultAtmCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(dependencies: externalDependencies)
    private lazy var legacyDependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: ATMExternalDependenciesResolver
    
    var childCoordinators: [Coordinator] = []
    lazy var dataBinding: DataBinding = dependencies.resolve()
    var onFinish: (() -> Void)?
    
    init(dependenciesResolver: ATMExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.legacyDependenciesEngine.resolve(for: AtmViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        setupDependenciesUseCase()
        self.legacyDependenciesEngine.register(for: AtmPresenterProtocol.self) { dependenciesResolver in
            return AtmPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: GetOffersCandidatesUseCase.self) { dependenciesResolver in
            return GetOffersCandidatesUseCase(dependenciesResolver: dependenciesResolver)
        }
      
        self.legacyDependenciesEngine.register(for: AtmViewController.self) { dependenciesResolver in
            let presenter: AtmPresenterProtocol = dependenciesResolver.resolve(for: AtmPresenterProtocol.self)
            let viewController = AtmViewController(nibName: "AtmViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.legacyDependenciesEngine.register(for: AtmCoordinatorProtocol.self) { _ in
            return self
        }
    }
    
    private func setupDependenciesUseCase() {
         self.legacyDependenciesEngine.register(for: GetAtmUseCase.self) { dependenciesResolver in
             return GetAtmUseCase(dependenciesResolver: dependenciesResolver)
         }

         self.legacyDependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
             return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
         }
        
        self.legacyDependenciesEngine.register(for: GetMovementsAtmUseCase.self) { dependenciesResolver in
            return GetMovementsAtmUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: GetAtmMovemetsSuperUseCase.self) { dependenciesResolver in
            return GetAtmMovemetsSuperUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: GetAccountUseCase.self) { dependenciesResolver in
            return GetAccountUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: LocationPermission.self) { dependenciesResolver in
            return LocationPermission(dependenciesResolver: dependenciesResolver)
        }
     }
}

extension DefaultAtmCoordinator: AtmCoordinatorProtocol {}

extension DefaultAtmCoordinator: ATMCoordinator { }

private extension DefaultAtmCoordinator {
    struct Dependency: ATMDependenciesResolver {
        let dependencies: ATMExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        
        var external: ATMExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
