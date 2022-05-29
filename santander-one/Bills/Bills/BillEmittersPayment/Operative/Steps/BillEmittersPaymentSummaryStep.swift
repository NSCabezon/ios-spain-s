//
//  BillEmittersPaymentSummaryStep.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 25/05/2020.
//

import Foundation
import CoreFoundationLib
import Operative

struct BillEmittersPaymentSummaryStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver

    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: true)
    }
    
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: OperativeSummaryViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
