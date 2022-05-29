//
//  HistoricExtractSteps.swift
//  Cards
//
//  Created by Ignacio González Miró on 17/11/2020.
//

import Foundation
import Operative
import CoreFoundationLib

final class HistoricExtractSteps: OperativeStep {
    let dependenciesResolver: DependenciesResolver

    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: HistoricExtractViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
