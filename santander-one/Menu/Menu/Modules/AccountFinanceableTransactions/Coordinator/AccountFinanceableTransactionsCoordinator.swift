//
//  AccountFinanceableTransactionsCoordinator.swift
//  Menu
//
//  Created by José Carlos Estela Anguita on 02/09/2020.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain

public protocol AccountFinanceableTransactionCoordinatorDelegate: AnyObject {
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectOffer(_ offer: OfferRepresentable?)
}

class AccountFinanceableTransactionCoordinator: ModuleCoordinator {
    var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.seupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: AccountFinanceableTransactionsViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func seupDependencies() {
        self.dependenciesEngine.register(for: GetAccountUseCase.self) { resolver in
            return GetAccountUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetAccountFinanceableTransactionsUseCase.self) { resolver in
            return GetAccountFinanceableTransactionsUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetAccountEasyPayUseCase.self) { resolver in
            GetAccountEasyPayUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetOffersCandidatesUseCase.self) { resolver in
            GetOffersCandidatesUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: ValidateEasyPayUseCase.self) { resolver in
            return ValidateEasyPayUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: AccountFinanceableTransactionsPresenterProtocol.self) { resolver in
            return AccountFinanceableTransactionsPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: AccountFinanceableTransactionsViewController.self) { resolver in
            let presenter = resolver.resolve(for: AccountFinanceableTransactionsPresenterProtocol.self)
            let controller = AccountFinanceableTransactionsViewController(nibName: "AccountFinanceableTransactionsViewController", bundle: .module, presenter: presenter)
            presenter.view = controller
            return controller
        }
    }
}
