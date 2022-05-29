//
//  BillEmittersPaymentOperativeExtension.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/14/20.
//

import Foundation
import Operative

extension BillEmittersPaymentOperative {
    
    func setupSearchEmitters() {
        self.dependencies.register(for: SearchEmitterUseCase.self) { resolver in
            return SearchEmitterUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: GetBillEmittersPaymentFieldsUseCase.self) { resolver in
            return GetBillEmittersPaymentFieldsUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: GetFrequentEmittersUseCase.self) { resolver in
            return GetFrequentEmittersUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: GetEmitterIncomesUseCase.self) { resolver in
            return GetEmitterIncomesUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SearchEmittersPresenterProtocol.self) { resolver in
            return SearchEmittersPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SearchEmittersViewProtocol.self) { resolver in
            return resolver.resolve(for: SearchEmittersViewController.self)
        }
        self.dependencies.register(for: SearchEmittersViewController.self) { resolver in
            let presenter = resolver.resolve(for: SearchEmittersPresenterProtocol.self)
            let viewController = SearchEmittersViewController(nibName: "SearchEmittersViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupBillEmittersPaymentConfirmation() {
        self.dependencies.register(for: GetBillEmittersPaymentFieldsUseCase.self) { resolver in
            return GetBillEmittersPaymentFieldsUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BillEmittersPaymentConfirmationPresenterProtocol.self) { resolver in
            BillEmittersPaymentConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BillEmittersPaymentConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: BillEmittersPaymentConfirmationViewController.self)
        }
        self.dependencies.register(for: BillEmittersPaymentConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: BillEmittersPaymentConfirmationPresenterProtocol.self)
            let viewController = BillEmittersPaymentConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupBillEmittersPaymentSummary() {
        self.dependencies.register(for: BillEmittersPaymentSummaryPresenterProtocol.self) { resolver in
            BillEmittersPaymentSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: BillEmittersPaymentSummaryPresenterProtocol.self)
            let viewController = OperativeSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupAccountSelector() {
        self.dependencies.register(for: BillEmittersPaymentAccountSelectorPresenterProtocol.self) { resolver in
            BillEmittersPaymentAccountSelectorPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BillEmittersPaymentAccountSelectorViewProtocol.self) { resolver in
            resolver.resolve(for: BillEmittersPaymentAccountSelectorViewController.self)
        }
        self.dependencies.register(for: BillEmittersPaymentAccountSelectorViewController.self) { resolver in
            let presenter = resolver.resolve(for: BillEmittersPaymentAccountSelectorPresenterProtocol.self)
            let viewController = BillEmittersPaymentAccountSelectorViewController(nibName: "BillEmittersPaymentAccountSelectorViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupBillEmittersManualPayment() {
        self.dependencies.register(for: ValidateFieldsManualPaymentUseCase.self) { _ in
            return ValidateFieldsManualPaymentUseCase()
        }
        self.dependencies.register(for: BillEmittersManualPaymentPresenterProtocol.self) { resolver in
            BillEmittersManualPaymentPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BillEmittersManualPaymentViewProtocol.self) { resolver in
            resolver.resolve(for: BillEmittersManualPaymentViewController.self)
        }
        self.dependencies.register(for: BillEmittersManualPaymentViewController.self) { resolver in
            let presenter = resolver.resolve(for: BillEmittersManualPaymentPresenterProtocol.self)
            let viewController = BillEmittersManualPaymentViewController(nibName: "BillEmittersManualPaymentViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
