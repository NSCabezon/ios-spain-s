//
//  LoanDetailCoordinatorSpy.swift
//  ExampleAppTests
//
//  LoanDetailCoordinatorSpy.swift
//

import CoreFoundationLib
import UI
@testable import Loans

class LoanTransactionSearchCoordinatorSpy: LoanTransactionSearchCoordinator {
    
    var dataBinding: DataBinding
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var didApplyFilterCalled: Bool = false
    var dismissCalled: Bool = false
    var startCalled: Bool = false
    
    init() {
        dataBinding = DataBindingObject()
        childCoordinators = []
    }
    
    func didApplyFilter(_ filter: TransactionFiltersEntity, criteria: CriteriaFilter) {
        self.didApplyFilterCalled = true
    }
    
    func dismiss() {
        self.dismissCalled = true
    }
    
    func start() {
        self.startCalled = true
    }
}
