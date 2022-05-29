//
//  BizumRefundMoneyConfirmationStep.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 9/12/20.
//

import Foundation
import Operative
import CoreFoundationLib

struct BizumRefundMoneyConfirmationStep: OperativeStep {
    
    private let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }

    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BizumRefundMoneyConfirmationViewProtocol.self)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
