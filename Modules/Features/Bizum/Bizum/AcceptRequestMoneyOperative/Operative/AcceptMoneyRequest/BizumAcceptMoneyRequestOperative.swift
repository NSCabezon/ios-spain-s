//
//  BizumAcceptMoneyRequestOperative.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 01/12/2020.
//

import Foundation
import Operative
import CoreFoundationLib

final class BizumAcceptMoneyRequestOperative: Operative {
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    lazy var operativeData: BizumAcceptMoneyRequestOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
          self.dependencies.resolve(for: BizumFinishingCoordinatorProtocol.self)
    }()
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = DependenciesDefault(father: dependencies)
        self.setupDependencies()
    }
}
