//
//  CardBoardingActivationOperativeExtension.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 06/10/2020.
//

import Foundation
import Operative

extension CardBoardingActivationOperative {
    
    func setupStartUsingCard() {
        
        self.dependencies.register(for: StartUsingCardPresenterProtocol.self) { resolver in
            return StartUsingCardPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: StartUsingCardViewProtocol.self) { resolver in
            return resolver.resolve(for: StartUsingCardViewController.self)
        }
        self.dependencies.register(for: StartUsingCardViewController.self) { resolver in
            let presenter = resolver.resolve(for: StartUsingCardPresenterProtocol.self)
            let viewController = StartUsingCardViewController(nibName: "StartUsingCardViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupSignature() {
        self.dependencies.register(for: SignCardBoardingActivationUseCase.self) { resolver in
            SignCardBoardingActivationUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupActivateCardSummary() {
        
        self.dependencies.register(for: ActivateCardSummaryPresenterProtocol.self) { resolver in
            return ActivateCardSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: ActivateCardSummaryViewProtocol.self) { resolver in
            return resolver.resolve(for: ActivateCardSummaryViewController.self)
        }
        self.dependencies.register(for: ActivateCardSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: ActivateCardSummaryPresenterProtocol.self)
            let viewController = ActivateCardSummaryViewController(nibName: "ActivateCardSummaryViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.dependencies.register(for: ActivatedCardUseCase.self) { dependenciesResolver in
            return ActivatedCardUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependencies.register(for: GetUpdatedCardUseCase.self) { dependenciesResolver in
            return GetUpdatedCardUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
    
    func setupUsecase() {
        self.dependencies.register(for: SetupActivateCardUseCaseProtocol.self) { resolver in
            return SetupActivateCardUseCase(dependenciesResolver: resolver)
        }
    }
}
