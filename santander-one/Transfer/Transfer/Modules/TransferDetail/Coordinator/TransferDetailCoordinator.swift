//
//  EmittedTransferDetailCoordinator.swift
//  Account
//
//  Created by Alvaro Royo on 17/6/21.
//

import Foundation
import CoreFoundationLib
import UI

protocol TransferDetailCoordinatorProtocol {
    func dismiss()
    func showComingSoonToast()
    func reuseTransferFromAccount(_ account: AccountEntity, destination: IBANEntity, beneficiary: String)
    func deleteStandingOrder(_ order: ScheduledTransferRepresentable, account: AccountEntity, detail: ScheduledTransferDetailEntity)
}

public class TransferDetailCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: TransferDetailViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    func goToDetail(with configuration: TransferDetailConfiguration) {
        self.dependenciesEngine.register(for: TransferDetailConfiguration.self) { _ in
            return configuration
        }
        start()
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: TransferDetailCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: TransferDetailPresenterProtocol.self) { resolver in
            return TransferDetailPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: EmittedTransferDetailViewProtocol.self) { resolver in
            return resolver.resolve(for: TransferDetailViewController.self)
        }
        self.dependenciesEngine.register(for: TransferDetailViewController.self) { resolver in
            var presenter = resolver.resolve(for: TransferDetailPresenterProtocol.self)
            let viewController = TransferDetailViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension TransferDetailCoordinator: TransferDetailCoordinatorProtocol {
    func deleteStandingOrder(_ order: ScheduledTransferRepresentable, account: AccountEntity, detail: ScheduledTransferDetailEntity) {
        let scheduledTransferCoordinator = self.dependenciesEngine.resolve(for: ScheduledTransfersCoordinatorDelegate.self)
        scheduledTransferCoordinator.deleteScheduledOrder(order, account: account, detail: detail)
    }
    
    func reuseTransferFromAccount(_ account: AccountEntity, destination: IBANEntity, beneficiary: String) {
        self.dependenciesEngine.register(for: TransfersHomeConfiguration.self) { _ in
            return TransfersHomeConfiguration(selectedAccount: account, isScaForTransactionsEnabled: false)
        }
        let homeModuleCoordinator = self.dependenciesEngine.resolve(for: TransferHomeModuleCoordinatorDelegate.self)
        homeModuleCoordinator.didSelectTransferAction(type: .reuse(destination, beneficiary), account: account)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showComingSoonToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}
