//
//  ChangeAliasStep.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/5/20.
//

import Foundation
import CoreFoundationLib

final class ChangeCardAliasStep: CardBoardingStep {
    private let dependenciesEngine: DependenciesDefault
    private var isFirstStep: Bool = false

    weak var view: CardBoardingStepView? {
        return self.dependenciesEngine.resolve(for: ChangeCardAliasViewController.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func setAsFirstStep() {
        self.isFirstStep = true
    }

    func setupDependencies() {
        self.dependenciesEngine.register(for: ChangeCardAliasNameUseCaseProtocol.self) { resolver in
            return ChangeCardAliasNameUseCase(dependenciesResolver: resolver)
        }
        
        self.dependenciesEngine.register(for: ChangeCardAliasPresenter.self) { resolver in
            return ChangeCardAliasPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: ChangeCardAliasViewController.self) { resolver in
            let presenter = resolver.resolve(for: ChangeCardAliasPresenter.self)
            let viewController = ChangeCardAliasViewController(nibName: "ChangeCardAliasViewController", bundle: .module, presenter: presenter)
            viewController.isFirstStep = self.isFirstStep
            presenter.view = viewController
            return viewController
        }
    }
}
