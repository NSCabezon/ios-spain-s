//
//  BillEmittersPaymentConfirmationStep.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 21/05/2020.
//

import Foundation
import CoreFoundationLib
import Operative

struct BillEmittersPaymentConfirmationStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver

    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BillEmittersPaymentConfirmationViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
