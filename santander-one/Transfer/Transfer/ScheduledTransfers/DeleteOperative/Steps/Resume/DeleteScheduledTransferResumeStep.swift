//
//  DeleteScheduledTransferResumeStep.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 20/7/21.
//

import Foundation
import Operative
import CoreFoundationLib

final class DeleteScheduledTransferResumeStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: true)
    }
    
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: OperativeSummaryViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
