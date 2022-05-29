//
//  CardSelectorStep.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 7/9/21.
//

import Foundation
import Operative
import CoreFoundationLib

final class CardSelectorStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: CardSelectorStepViewProtocol.self)
    }
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
