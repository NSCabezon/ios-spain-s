//
//  SelectAmortizationStep.swift
//  Loans
//
//  Created by Andres Aguirre Juarez on 24/9/21.
//

import CoreFoundationLib
import Operative

final class SelectAmortizationStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        dependenciesResolver.resolve(for: SelectAmortizationStepViewProtocol.self)
    }
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
