//
//  CardTransactionsSearchCoordinator.swift
//  Cards
//
//  Created by Tania Castellano Brasero on 13/02/2020.
//

import CoreFoundationLib
import UI

protocol CardTransactionsSearchDelegate: AnyObject {
    // Return card type in order to know the track id for metrics
    @discardableResult func didApplyFilter(_ filter: TransactionFiltersEntity, _ criteria: CriteriaFilter) -> String?
    func getFilters() -> TransactionFiltersEntity?
}

final class CardTransactionsSearchCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    weak var rootViewController: CardTransactionsSearchViewController?
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    init(resolver: DependenciesResolver, coordinatingViewController controller: UINavigationController?) {
        
        self.dependenciesEngine = DependenciesDefault(father: resolver)
        self.navigationController = controller
        
        self.dependenciesEngine.register(for: CardTransactionsSearchPresenterProtocol.self) { dependenciesResolver in
            return CardTransactionsSearchPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: CardTransactionsSearchViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: CardTransactionsSearchViewController.self)
        }
                
        self.dependenciesEngine.register(for: CardTransactionsSearchViewController.self) { dependenciesResolver in
            let presenter: CardTransactionsSearchPresenterProtocol = dependenciesResolver.resolve(for: CardTransactionsSearchPresenterProtocol.self)
            let viewController = CardTransactionsSearchViewController(nibName: "CardTransactionsSearchViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: CardTransactionsSearchCoordinator.self) { _ in
            return self
        }
    }
    
    func start() {
         self.navigationController?.blockingPushViewController(dependenciesEngine.resolve(for: CardTransactionsSearchViewController.self), animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
