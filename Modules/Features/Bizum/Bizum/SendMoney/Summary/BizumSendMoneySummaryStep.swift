//
//  BizumSendMoneySummaryStep.swift
//  Bizum
//
//  Created by Jose C. Yebes on 30/09/2020.
//

import Foundation
import CoreFoundationLib
import Operative

struct BizumSendMoneySummaryStep: OperativeStep {
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
