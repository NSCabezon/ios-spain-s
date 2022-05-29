//
//  ManualPaymentStep.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 21/05/2020.
//

import Foundation
import Operative
import CoreFoundationLib

final class BillEmittersManualPaymentStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver

    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BillEmittersManualPaymentViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
