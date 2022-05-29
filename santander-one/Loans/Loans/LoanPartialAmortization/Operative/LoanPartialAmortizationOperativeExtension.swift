//
//  LoanPartialAmortizationOperativeExtension.swift
//  Loans
//
//  Created by Andres Aguirre Juarez on 22/9/21.
//

import Foundation
import Operative
import SANLegacyLibrary

extension LoanPartialAmortizationOperative {
    func setupSelectAmortizationStep() {
        self.dependencies.register(for: SelectAmortizationStepPresenterProtocol.self) { resolver in
            return SelectAmortizationStepPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SelectAmortizationStepViewProtocol.self) { resolver in
            return resolver.resolve(for: SelectAmortizationStepViewController.self)
        }
        self.dependencies.register(for: SelectAmortizationStepViewController.self) { resolver in
            let presenter = resolver.resolve(for: SelectAmortizationStepPresenterProtocol.self)
            let viewController = SelectAmortizationStepViewController(nibName: "\(SelectAmortizationStepViewController.self)", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }

    func setupConfirmAmortizationStep() {
        self.dependencies.register(for: ConfirmationAmortizationStepPresenterProtocol.self) { resolver in
            return ConfirmationAmortizationStepPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: ConfirmationAmortizationStepViewProtocol.self) { resolver in
            return resolver.resolve(for: ConfirmationAmortizationStepViewController.self)
        }
        self.dependencies.register(for: ConfirmationAmortizationStepViewController.self) { resolver in
            let presenter = resolver.resolve(for: ConfirmationAmortizationStepPresenterProtocol.self)
            let viewController = ConfirmationAmortizationStepViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }

    func setupSummaryAmortizationStep() {
        self.dependencies.register(for: SummaryAmortizationStepPresenterProtocol.self) { resolver in
            return SummaryAmortizationStepPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SummaryAmortizationStepViewProtocol.self) { resolver in
            return resolver.resolve(for: SummaryAmortizationStepViewController.self)
        }
        self.dependencies.register(for: SummaryAmortizationStepViewController.self) { resolver in
            let presenter = resolver.resolve(for: SummaryAmortizationStepPresenterProtocol.self)
            let viewController = SummaryAmortizationStepViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }

    func setupUseCases() {
        self.dependencies.register(for: PrevalidatePartialAmortizationUseCaseProtocol.self) { resolver in
            return PrevalidatePartialAmortizationUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: ValidateLoanPartialAmortizationUseCaseProtocol.self) { resolver in
            return ValidateLoanPartialAmortizationUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: ConfirmLoanPartialAmortizationUseCaseProtocol.self) { resolver in
            return ConfirmLoanPartialAmortizationUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SetupLoanPartialAmortizationUseCaseProtocol.self) { resolver in
            return SetupLoanPartialAmortizationUseCase(dependenciesResolver: resolver)
        }
    }
}
