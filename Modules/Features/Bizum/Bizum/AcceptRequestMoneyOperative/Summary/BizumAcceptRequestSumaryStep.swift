//
//  BizumAcceptRequestSumaryStep.swift
//  Bizum
//
//  Created by Boris Chirino Fernandez on 03/12/2020.
//

import CoreFoundationLib
import Operative

struct BizumAcceptRequestSumaryStep: OperativeStep {
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
