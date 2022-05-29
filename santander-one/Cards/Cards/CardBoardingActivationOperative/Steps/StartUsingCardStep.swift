//
//  StartUsingCardStep.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 06/10/2020.
//

import Foundation
import Operative
import CoreFoundationLib

final class StartUsingCardStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver

    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: false)
    }
    
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: StartUsingCardViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
