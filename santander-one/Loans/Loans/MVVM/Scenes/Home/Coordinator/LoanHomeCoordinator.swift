//
//  LoanHomeCoordinator.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 10/1/21.
//  

import UI
import CoreFoundationLib
import CoreDomain
import OpenCombine
import UIKit

protocol LoanHomeCoordinator: BindableCoordinator {
    func openMenu()
    func gotoGlobalSearch()
    func goToRepayment(with loan: LoanRepresentable)
    func goToLoanDetail(with loan: LoanRepresentable, detail: LoanDetailRepresentable)
    func goToChangeLinkedAccount(with loan: LoanRepresentable)
    func gotoLoanCustomeOption(with loan: LoanRepresentable, option: LoanOptionRepresentable)
    func share(_ shareable: Shareable, type: ShareType)
    func goToFilter(with loan: LoanRepresentable, filters: LoanFilterRepresentable?, filterOutsider: LoanFilterOutsider)
    func gotoLoanTransactionDetail(transaction: LoanTransactionRepresentable, transactions: [LoanTransactionRepresentable], loan: LoanRepresentable)
}

// MARK: - Loan Coordinator
final class DefaultLoanHomeCoordinator: LoanHomeCoordinator {
    var onFinish: (() -> Void)?
    weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: LoanHomeExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: LoanHomeExternalDependenciesResolver,
                navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultLoanHomeCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func goToRepayment(with loan: LoanRepresentable) {
        let coordinator = dependencies.external.loanRepaymentCoordinator()
        coordinator.set(loan).start()
        append(child: coordinator)
    }
    
    func goToLoanDetail(with loan: LoanRepresentable, detail: LoanDetailRepresentable) {
        let coordinator = dependencies.external.loanDetailCoordinator()
        coordinator
            .set(loan)
            .set(detail)
            .start()
        append(child: coordinator)
    }
    
    func goToChangeLinkedAccount(with loan: LoanRepresentable) {
        let coordinator = dependencies.external.loanChangeLinkedAccountCoordinator()
        coordinator.set(loan).start()
        append(child: coordinator)
    }
    
    func gotoLoanCustomeOption(with loan: LoanRepresentable, option: LoanOptionRepresentable) {
        let coordinator = dependencies.external.loanCustomeOptionCoordinator()
        coordinator
            .set(loan)
            .set(option)
            .start()
        append(child: coordinator)
    }

    func share(_ shareable: Shareable, type: ShareType) {
        let coordinator: ShareCoordinator = dependencies.external.resolve()
        coordinator
            .set(shareable)
            .set(type)
            .start()
        append(child: coordinator)
    }
    
    func goToFilter(with loan: LoanRepresentable, filters: LoanFilterRepresentable?, filterOutsider: LoanFilterOutsider) {
        let coordinator = dependencies.external.loanTransactionsSearchCoordinator()
        coordinator
            .set(loan)
            .set(filterOutsider)
            .set(filters)
            .start()
        append(child: coordinator)
    }
    
    func gotoLoanTransactionDetail(transaction: LoanTransactionRepresentable, transactions: [LoanTransactionRepresentable], loan: LoanRepresentable) {
        let coordinator = dependencies.external.loanTransactionDetailCoordinator()
        coordinator
            .set(transaction)
            .set(transactions)
            .set(loan)
            .start()
        append(child: coordinator)
    }
    
    func openMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func gotoGlobalSearch() {
        let coordinator = dependencies.external.globalSearchCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
}

private extension DefaultLoanHomeCoordinator {
    struct Dependency: LoanHomeDependenciesResolver {
        let dependencies: LoanHomeExternalDependenciesResolver
        let coordinator: LoanHomeCoordinator
        let dataBinding = DataBindingObject()
        
        var external: LoanHomeExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> LoanHomeCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
