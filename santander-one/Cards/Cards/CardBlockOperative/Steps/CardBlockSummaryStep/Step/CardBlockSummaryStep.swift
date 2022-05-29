//
//  CardBlockSummaryStep.swift
//  Cards
//
//  Created by Laura González on 31/05/2021.
//

import Operative
import CoreFoundationLib

final class CardBlockSummaryStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        dependenciesResolver.resolve(for: CardBlockSummaryStepViewProtocol.self)
    }
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
