//
//  CardBlockOperativeExtension.swift
//  Cards
//
//  Created by Laura González on 03/06/2021.
//

import Foundation
import Operative

extension CardBlockOperative {
    func setupCardBlockSummary() {
        self.dependencies.register(for: CardBlockSummaryStepPresenterProtocol.self) { resolver in
            return CardBlockSummaryStepPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: CardBlockSummaryStepViewProtocol.self) { resolver in
            return resolver.resolve(for: CardBlockSummaryStepViewController.self)
        }
        self.dependencies.register(for: CardBlockSummaryStepViewController.self) { resolver in
            let presenter = resolver.resolve(for: CardBlockSummaryStepPresenterProtocol.self)
            let viewController = CardBlockSummaryStepViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupCardBlockReason() {
        self.dependencies.register(for: CardBlockReasonPresenterProtocol.self) { resolver in
            return CardBlockReasonPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: CardBlockReasonViewProtocol.self) { resolver in
            return resolver.resolve(for: CardBlockReasonViewController.self)
        }
        self.dependencies.register(for: CardBlockReasonViewController.self) { resolver in
            let presenter = resolver.resolve(for: CardBlockReasonPresenterProtocol.self)
            let viewController = CardBlockReasonViewController(nibName: "\(CardBlockReasonViewController.self)", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupUseCases() {
        self.dependencies.register(for: ConfirmCardBlockUseCaseProtocol.self) { resolver in
            return ConfirmCardBlockUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SetupCardBlockUseCaseProtocol.self) { resolver in
            return SetupCardBlockUseCase(dependenciesResolver: resolver)
        }
    }
}
