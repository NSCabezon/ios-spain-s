//
//  SummaryStep.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/14/20.
//

import CoreFoundationLib
import Foundation

final class CardBoardingSummaryStep: CardBoardingStep {
    private let dependenciesEngine: DependenciesDefault
    private var isFirstStep: Bool = false

    weak var view: CardBoardingStepView? {
        self.dependenciesEngine.resolve(for: CardBoardingSummaryViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func setAsFirstStep() {
        self.isFirstStep = true
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: CardBoardingSummaryPresenterProtocol.self) { resolver in
            return CardBoardingSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: CardBoardingSummaryViewProtocol.self) { resolver in
            var presenter = resolver.resolve(for: CardBoardingSummaryPresenterProtocol.self)
            let viewController = CardBoardingSummaryViewController(nibName: "CardBoardingSummaryViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension CardBoardingStep where Self: CardBoardingSummaryStep {
    func showTopBarItems() -> Bool {
        return false
    }
}
