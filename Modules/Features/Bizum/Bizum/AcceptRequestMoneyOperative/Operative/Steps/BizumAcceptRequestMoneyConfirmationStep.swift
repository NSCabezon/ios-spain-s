//
//  BizumAcceptRequestMoneyConfirmationStep.swift
//  Bizum
//
//  Created by Cristobal Ramos Laina on 03/12/2020.
//

import Foundation
import Operative
import CoreFoundationLib

final class BizumAcceptRequestMoneyConfirmationStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver

    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BizumAcceptRequestMoneyConfirmationViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
