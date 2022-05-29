//
//  AccountTransactionsSearchCoordinator.swift
//  Account
//
//  Created by Tania Castellano Brasero on 30/01/2020.
//

import CoreFoundationLib
import UI

protocol AccountTransactionsSearchDelegate: AnyObject {
    func didApplyFilter(_ filter: TransactionFiltersEntity, _ criteria: CriteriaFilter)
    func getFilters() -> TransactionFiltersEntity?
    func finishOTPSuccess(_ activeFilter: TransactionFiltersEntity?)
    func getSelectedAccount() -> AccountEntity?
}

final class AccountTransactionsSearchCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    weak var rootViewController: AccountTransactionsSearchViewController?
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    init(resolver: DependenciesResolver, coordinatingViewController controller: UINavigationController?) {
        
        self.dependenciesEngine = DependenciesDefault(father: resolver)
        self.navigationController = controller
        
        self.dependenciesEngine.register(for: AccountTransactionsSearchPresenterProtocol.self) { dependenciesResolver in
            return AccountTransactionsSearchPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: AccountTransactionsSearchViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: AccountTransactionsSearchViewController.self)
        }
                
        self.dependenciesEngine.register(for: AccountTransactionsSearchViewController.self) { dependenciesResolver in
            let presenter: AccountTransactionsSearchPresenterProtocol = dependenciesResolver.resolve(for: AccountTransactionsSearchPresenterProtocol.self)
            let viewController = AccountTransactionsSearchViewController(nibName: "AccountTransactionsSearchViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: AccountTransactionsSearchCoordinator.self) { _ in
            return self
        }
    }
    
    func start() {
         self.navigationController?.blockingPushViewController(dependenciesEngine.resolve(for: AccountTransactionsSearchViewController.self), animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func goToHome() {
        if let viewController = self.navigationController?.viewControllers.filter({$0 is AccountTransactionsSearchViewController}).first as? AccountTransactionsSearchViewController {
            self.navigationController?.popToViewController(viewController, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
