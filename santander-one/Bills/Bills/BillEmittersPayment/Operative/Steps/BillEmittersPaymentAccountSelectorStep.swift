//
//  BillEmittersPaymentAccountSelectorStep.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 21/05/2020.
//

import Foundation
import Operative
import CoreFoundationLib

final class BillEmittersPaymentAccountSelectorStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BillEmittersPaymentAccountSelectorViewProtocol.self)
    }
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
