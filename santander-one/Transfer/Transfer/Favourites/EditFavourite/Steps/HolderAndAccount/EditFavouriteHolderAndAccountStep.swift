//
//  EditFavouriteHolderAndAccountStep.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 26/07/2021.
//

import Foundation
import Operative
import CoreFoundationLib

final class EditFavouriteHolderAndAccountStep: OperativeStep {

   let dependenciesResolver: DependenciesResolver
   weak var view: OperativeView? {
       self.dependenciesResolver.resolve(for: EditFavouriteHolderAndAccountViewProtocol.self)
    }
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
