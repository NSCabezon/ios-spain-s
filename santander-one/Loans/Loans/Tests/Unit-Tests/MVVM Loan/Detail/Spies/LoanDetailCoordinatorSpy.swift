//
//  LoanDetailCoordinatorSpy.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 28/2/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreFoundationLib
import UI
@testable import Loans

class LoanDetailCoordinatorSpy: LoanDetailCoordinator {
    
    var dataBinding: DataBinding
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var shareCalled: Bool = false
    var didSelectMenuCalled: Bool = false
    var startCalled: Bool = false
    var dismissCalled: Bool = false
    
    init() {
        dataBinding = DataBindingObject()
        childCoordinators = []
    }
    
    func share(_ shareable: Shareable, type: ShareType) {
        shareCalled = true
    }
    
    func didSelectMenu() {
        didSelectMenuCalled = true
    }
    
    func start() {
        startCalled = true
    }
    
    func dismiss() {
        dismissCalled = true
    }
}
