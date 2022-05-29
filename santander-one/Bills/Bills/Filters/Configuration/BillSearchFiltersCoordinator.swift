//
//  BillSearchFiltersCoordinator.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/17/20.
//

import Foundation
import UI
import CoreFoundationLib

protocol BillSearchFiltersCoordinatorProtocol {
    func dismiss()
    func goToChangeAccount()
}

public protocol BillSearchFiltersCoordinatorDelegate: AnyObject {
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?)
}

final class BillSearchFiltersCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: BillSearchFiltersViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        let presenter = BillSearchFiltersPresenter(dependenciesResolver: dependenciesEngine)

        self.dependenciesEngine.register(for: BillSearchFiltersPresenterProtocol.self) { _ in
            return presenter
        }
        
        self.dependenciesEngine.register(for: BillAccountSelector.self) { _ in
            return presenter
        }
        
        self.dependenciesEngine.register(for: BillSearchFiltersCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: BillSearchFiltersViewController.self) { dependenciesResolver in
            var presenter = dependenciesResolver.resolve(for: BillSearchFiltersPresenterProtocol.self)
            let controller = BillSearchFiltersViewController(nibName: "BillSearchFiltersViewController", bundle: .module, presenter: presenter)
            presenter.view = controller
            return controller
        }
    }
}

extension BillSearchFiltersCoordinator: BillSearchFiltersCoordinatorProtocol {
    func goToChangeAccount() {
        BillAccountSelectorCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: self.navigationController
        ).start()
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
