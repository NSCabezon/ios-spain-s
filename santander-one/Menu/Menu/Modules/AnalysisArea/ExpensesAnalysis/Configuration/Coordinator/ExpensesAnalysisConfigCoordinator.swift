//
//  ExpensesAnalysisConfigCoordinator.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 29/6/21.
//

import Foundation
import CoreFoundationLib
import UI

protocol ExpensesAnalysisConfigCoordinatorProtocol {
    func dismiss()
    func didPressAddOtherBanks()
    func didPressOtherBankConfig(_ viewModel: OtherBankConfigViewModel)
}

final class ExpensesAnalysisConfigCoordinator: ModuleCoordinator {
    private let dependenciesEngine: DependenciesDefault
    weak var navigationController: UINavigationController?
    private let bankDetailConfigurationCoordinator: BankConfigurationDetailCoordinator
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.bankDetailConfigurationCoordinator = BankConfigurationDetailCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: navigationController
        )
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: ExpensesAnalysisConfigViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

private extension ExpensesAnalysisConfigCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: ExpensesAnalysisConfigCoordinatorProtocol.self) {_ in
            return self
        }
        self.dependenciesEngine.register(for: ExpensesAnalysisConfigPresenterProtocol.self) { dependenciesResolver in
            return ExpensesAnalysisConfigPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: ExpensesAnalysisConfigViewController.self) { _ in
            var presenter = self.dependenciesEngine.resolve(for: ExpensesAnalysisConfigPresenterProtocol.self)
            let viewController = ExpensesAnalysisConfigViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: GetConfigurationAccountsUseCase.self) { _ in
            return GetConfigurationAccountsUseCase()
        }
    }
}

extension ExpensesAnalysisConfigCoordinator: ExpensesAnalysisConfigCoordinatorProtocol {
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didPressAddOtherBanks() {
        
    }
    
    func didPressOtherBankConfig(_ viewModel: OtherBankConfigViewModel) {
        self.dependenciesEngine.register(for: BankConfigurationDetailConfiguration.self) { _ in
            return BankConfigurationDetailConfiguration(selectedBank: viewModel)
        }
        self.bankDetailConfigurationCoordinator.start()
    }
}
