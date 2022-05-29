//
//  CardBoardingGeolocationStep.swift
//  Cards
//
//  Created by Carlos Monfort Gómez on 11/11/2020.
//

import Foundation
import CoreFoundationLib

final class CardBoardingGeolocationStep: CardBoardingStep {
    private let dependenciesEngine: DependenciesDefault
    private var isFirstStep: Bool = false

    weak var view: CardBoardingStepView? {
        return self.dependenciesEngine.resolve(for: CardBoardingGeolocationViewController.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func setAsFirstStep() {
        self.isFirstStep = true
    }
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: CardBoardingGeolocationPresenter.self) { resolver in
            return CardBoardingGeolocationPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: CardBoardingGeolocationViewController.self) { resolver in
            let presenter = resolver.resolve(for: CardBoardingGeolocationPresenter.self)
            let viewController = CardBoardingGeolocationViewController(nibName: "CardBoardingGeolocationViewController", bundle: .module, presenter: presenter)
            viewController.isFirstStep = self.isFirstStep
            presenter.view = viewController
            return viewController
        }
    }
}
