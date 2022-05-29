//
//  LoanChangeLinkedAccountCoordinator.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/17/21.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain

final class LoanChangeLinkedAccountCoordinator: BindableCoordinator {
    var onFinish: (() -> Void)?
    var dataBinding: DataBinding = DataBindingObject()
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    private let dependencies: RetailLegacyLoanExternalDependenciesResolver
    private lazy var legacyDependencies: DependenciesResolver = dependencies.resolve()

    init(dependencies: RetailLegacyLoanExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func start() {
        guard let loanRepresentable: LoanRepresentable = dataBinding.get() else {
            return
        }
        let loanEntity = LoanEntity(loanRepresentable)
        legacyDependencies
            .resolve(for: LoansHomeCoordinatorNavigator.self)
            .didSelectChangeLinkedAccount(for: loanEntity)
    }
}
