//
//  CardOnOffSummaryStep.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 30/8/21.
//

import Foundation
import Operative
import CoreFoundationLib

final class CardOnOffSummaryStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        dependenciesResolver.resolve(for: CardOnOffSummaryStepViewProtocol.self)
    }
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
