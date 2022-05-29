//
//  BizumSplitExpensesOperative.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 11/01/2021.
//

import Foundation
import Operative
import CoreFoundationLib

class BizumSplitExpensesOperative: BizumMoneyOperative {
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    lazy var operativeData: BizumSplitExpensesOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
          self.dependencies.resolve(for: BizumSplitExpensesFinishingCoordinatorProtocol.self)
    }()
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = DependenciesDefault(father: dependencies)
        self.setupDependencies()
    }
}
