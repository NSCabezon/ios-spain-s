//
//  LoanTransactionDetailCoordinator.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 20/8/21.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

public protocol LoanTransactionDetailCoordinatorProtocol: AnyObject {
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectAction(_ action: LoanActionType, entity: LoanEntity)
}

final class OldLoanTransactionDetailCoordinator: ModuleCoordinator {

    private let dependenciesEngine: DependenciesDefault
    weak var navigationController: UINavigationController?
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    func start() {
        self.navigationController?.blockingPushViewController(dependenciesEngine.resolve(for: LoanTransactionDetailViewController.self), animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}

private extension OldLoanTransactionDetailCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: LoanTransactionDetailUseCase.self) { dependenciesResolver in
            return LoanTransactionDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: LoanTransactionDetailPresenterProtocol.self) { dependenciesResolver in
            return LoanTransactionDetailPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: OldLoanTransactionDetailViewController.self) { dependenciesResolver in
            let presenter: LoanTransactionDetailPresenterProtocol = dependenciesResolver.resolve(for: LoanTransactionDetailPresenterProtocol.self)
            let viewController = OldLoanTransactionDetailViewController(nibName: "LoanTransactionDetail", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
