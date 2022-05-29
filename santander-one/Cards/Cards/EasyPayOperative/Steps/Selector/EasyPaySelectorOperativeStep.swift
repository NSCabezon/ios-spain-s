//
//  EasyPaySelectorOperativeStep.swift
//  Cards
//
//  Created by alvola on 14/12/2020.
//

import Operative
import CoreFoundationLib

struct EasyPaySelectorOperativeStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: EasyPaySelectorViewProtocol.self)
    }
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
