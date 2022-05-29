//
//  PendingTransactionDetailCoordinator.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 9/16/20.
//
import UI
import CoreFoundationLib
import Foundation

protocol PendingTransactionDetailCoordinatorProtocol {
    func didSelectDismiss()
}

protocol PendingTransactionDetailCoordinatorDelegate: AnyObject {
    func didSelectMenu()
    func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity)
}

final class PendingTransactionDetailCoordinator: ModuleCoordinator {
    var navigationController: UINavigationController?
    var dependenciesEngine: DependenciesDefault
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.registerDependencies()
    }
    
    func start() {
        let viewController = self.dependenciesEngine.resolve(for: PendingTransactionDetailViewController.self)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func registerDependencies() {
        self.dependenciesEngine.register(for: PendingTransactionDetailCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: PendingTransactionDetailPresenterProtocol.self) { resolver in
            return PendingTransactionDetailPresenter(dependenciesResolver: resolver)
        }
        
        self.dependenciesEngine.register(for: PendingTransactionDetailViewController.self) { resolver in
            var presenter = resolver.resolve(for: PendingTransactionDetailPresenterProtocol.self)
            let view = PendingTransactionDetailViewController(
                nibName: "PendingTransactionDetailViewController", bundle: .module, presenter: presenter)
            presenter.view = view
            return view
        }
    }
}

extension PendingTransactionDetailCoordinator: PendingTransactionDetailCoordinatorProtocol {
    func didSelectDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
