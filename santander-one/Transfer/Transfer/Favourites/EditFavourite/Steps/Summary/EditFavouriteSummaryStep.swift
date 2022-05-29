//
//  EditFavouriteSummaryStep.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 12/08/2021.
//

import Operative
import CoreFoundationLib

final class EditFavouriteSummaryStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: OperativeSummaryViewProtocol.self)
    }
    
    var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: false, showsCancel: false)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
