//
//  EasyPayConfigurationOperativeStep.swift
//  Cards
//
//  Created by alvola on 02/12/2020.
//

import Operative
import CoreFoundationLib

struct EasyPayConfigurationOperativeStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: EasyPayConfigurationViewProtocol.self)
    }
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
