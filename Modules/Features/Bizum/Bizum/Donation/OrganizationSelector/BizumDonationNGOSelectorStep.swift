//
//  BizumDonationNGOSelectorStep.swift
//  Bizum

import Operative
import CoreFoundationLib

final class BizumDonationNGOSelectorStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BizumDonationNGOSelectorViewProtocol.self)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
