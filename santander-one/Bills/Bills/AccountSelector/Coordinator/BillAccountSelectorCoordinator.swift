//
//  BillAccountSelectorCoordinator.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 17/04/2020.
//

import Foundation
import CoreFoundationLib
import UI

protocol BillAccountSelectorCoordinatorProtocol {
    func dismiss()
}

final class BillAccountSelectorCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: BillAccountSelectorViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: BillAccountSelectorCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: BillAccountSelectorPresenter.self) { dependenciesResolver in
            return BillAccountSelectorPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetAccountsUseCase.self) { dependenciesResolver in
            return GetAccountsUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: BillAccountSelectorViewController.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: BillAccountSelectorPresenter.self)
            let view = BillAccountSelectorViewController(nibName: "BillAccountSelectorViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = view
            return view
        }
    }
}

extension BillAccountSelectorCoordinator: BillAccountSelectorCoordinatorProtocol {
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
