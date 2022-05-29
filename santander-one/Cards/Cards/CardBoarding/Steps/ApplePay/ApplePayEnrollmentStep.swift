//
//  ApplePayEnrollmentStep.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/7/20.
//

import Foundation
import CoreFoundationLib

final class ApplePayEnrollmentStep: CardBoardingStep {
    private var dependenciesEngine: DependenciesDefault
    private var isFirstStep: Bool = false

    weak var view: CardBoardingStepView? {
        return self.dependenciesEngine.resolve(for: ApplePayEnrollmentViewController.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func setAsFirstStep() {
          self.isFirstStep = true
    }
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { resolver in
            return GetPullOffersUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: ApplePayEnrollmentPresenterProtocol.self) { resolver in
            return ApplePayEnrollmentPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: ApplePayEnrollmentViewController.self) { resolver in
            var presenter = resolver.resolve(for: ApplePayEnrollmentPresenterProtocol.self)
            let viewController = ApplePayEnrollmentViewController(nibName: "ApplePayEnrollmentViewController", bundle: .module, presenter: presenter)
            viewController.isFirstStep = self.isFirstStep
            presenter.view = viewController
            return viewController
        }
    }
}
