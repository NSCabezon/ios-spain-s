//
//  CardBlockReasonStep.swift
//  Cards
//
//  Created by Laura González on 01/06/2021.
//

import Operative
import CoreFoundationLib

final class CardBlockReasonStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        dependenciesResolver.resolve(for: CardBlockReasonViewProtocol.self)
    }
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
