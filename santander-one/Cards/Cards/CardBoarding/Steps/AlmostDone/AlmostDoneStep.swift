//
//  AlmostDoneStep.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 16/10/2020.
//

import CoreFoundationLib

final class AlmostDoneStep: CardBoardingStep {
    private let dependenciesEngine: DependenciesDefault
    private var isFirstStep: Bool = false
    
    weak var view: CardBoardingStepView? {
        return self.dependenciesEngine.resolve(for: AlmostDoneViewController.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func setAsFirstStep() {
        self.isFirstStep = true
    }
}

private extension AlmostDoneStep {
    func setupDependencies() {
        self.dependenciesEngine.register(for: AlmostDonePresenterProtocol.self) { resolver in
            return AlmostDonePresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: AlmostDoneViewController.self) { resolver in
            let presenter = resolver.resolve(for: AlmostDonePresenterProtocol.self)
            let viewController = AlmostDoneViewController(nibName: AlmostDoneViewController.nibName, bundle: .module, presenter: presenter)
            viewController.isFirstStep = self.isFirstStep
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: GetAlmostDoneCardTipsUseCase.self) { resolver in
            return GetAlmostDoneCardTipsUseCase(dependenciesResolver: resolver)
        }
    }
}
