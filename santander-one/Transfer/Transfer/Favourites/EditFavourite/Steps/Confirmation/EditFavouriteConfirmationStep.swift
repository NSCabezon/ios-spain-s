//
//  EditFavouriteConfirmationStep.swift
//  Account
//
//  Created by Jose Enrique Montero Prieto on 27/07/2021.
//

import Foundation
import CoreFoundationLib
import Operative

struct EditFavouriteConfirmationStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver

    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: EditFavouriteConfirmationViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
