//
//  BizumRefundMoneySummaryStep.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 11/12/20.
//

import Foundation
import Operative
import CoreFoundationLib

struct BizumRefundMoneySummaryStep: OperativeStep {
    
    private let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: true)
    }
    
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: OperativeSummaryViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
