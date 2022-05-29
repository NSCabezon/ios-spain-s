//
//  NotificationsStep.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 04/11/2020.
//

import Foundation
import CoreFoundationLib

final class NotificationsStep: CardBoardingStep {
    private let dependenciesEngine: DependenciesDefault
    private var isFirstStep: Bool = false

    weak var view: CardBoardingStepView? {
        return self.dependenciesEngine.resolve(for: NotificationsViewController.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func setAsFirstStep() {
        self.isFirstStep = true
    }

    func setupDependencies() {
     
        self.dependenciesEngine.register(for: NotificationsPresenter.self) { resolver in
            return NotificationsPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: NotificationsViewController.self) { resolver in
            let presenter = resolver.resolve(for: NotificationsPresenter.self)
            let viewController = NotificationsViewController(nibName: "NotificationsViewController", bundle: .module, presenter: presenter)
            viewController.isFirstStep = self.isFirstStep
            presenter.view = viewController
            return viewController
        }
    }
}
