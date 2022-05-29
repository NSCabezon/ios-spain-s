//
//  BizumSplitExpensesAmountStep.swift
//  Bizum

import Operative
import CoreFoundationLib

final class BizumSplitExpensesAmountStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }

    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BizumSplitExpensesAmountViewProtocol.self)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
