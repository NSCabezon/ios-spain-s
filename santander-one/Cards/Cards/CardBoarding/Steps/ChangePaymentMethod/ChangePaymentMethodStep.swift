//
//  ChangePaymentMethodStep.swift
//  Cards
//
//  Created by Carlos Monfort Gómez on 07/10/2020.
//

import Foundation
import CoreFoundationLib

final class ChangePaymentMethodStep: CardBoardingStep {
    private let dependenciesEngine: DependenciesDefault
    private var isFirstStep: Bool = false

    weak var view: CardBoardingStepView? {
        return self.dependenciesEngine.resolve(for: ChangePaymentMethodViewController.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func setAsFirstStep() {
        self.isFirstStep = true
    }
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: ChangePaymentMethodPresenter.self) { resolver in
            return ChangePaymentMethodPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: ChangePaymentMethodViewController.self) { resolver in
            let presenter = resolver.resolve(for: ChangePaymentMethodPresenter.self)
            let viewController = ChangePaymentMethodViewController(nibName: "ChangePaymentMethodViewController", bundle: .module, presenter: presenter)
            viewController.isFirstStep = self.isFirstStep
            presenter.view = viewController
            return viewController
        }
    }
}
