//
//  ActivateCardSummaryStep.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 13/10/2020.
//

import Foundation
import Operative
import CoreFoundationLib

final class ActivateCardSummaryStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver

    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: false)
    }
    
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: ActivateCardSummaryViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
