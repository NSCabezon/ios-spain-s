//
//  ScheduledTransfersCoordinator.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 31/01/2020.
//

import Foundation
import CoreFoundationLib
import UI

public protocol ScheduledTransfersCoordinatorDelegate: AnyObject {
    func didSelectNewShipment(for account: AccountEntity?)
    func didSelectScheduledTransferDetail(for entity: ScheduledTransferEntity,
                                          account: AccountEntity, originAcount: AccountEntity?)
    func didSelectDismiss()
    func didSelectMenu()
    func deleteScheduledOrder(
        _ order: ScheduledTransferRepresentable,
        account: AccountEntity,
        detail: ScheduledTransferDetailEntity
    )
}

final class ScheduledTransfersCoordinator: ModuleCoordinator {
    
    weak var navigationController: UINavigationController?
    let dependenciesEngine: DependenciesDefault
    
    private let transferDetailCoordinator: TransferDetailCoordinator
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.transferDetailCoordinator = TransferDetailCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: ScheduledTransfersViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    // MARK: - Private
    private func setupDependencies() {
        self.dependenciesEngine.register(for: ScheduledTransfersCoordinator.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: ScheduledTransfersPresenterProtocol.self) { dependenciesResolver in
            return ScheduledTransfersPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetAllScheduledTransferUseCase.self) { dependenciesResolver in
            return GetAllScheduledTransferUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: LoadScheduledTransferSuperUseCase.self) { dependenciesResolver in
            return LoadScheduledTransferSuperUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: ScheduledTransfersViewController.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: ScheduledTransfersPresenterProtocol.self)
            let view = ScheduledTransfersViewController(nibName: "ScheduledTransfersViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = view
            return view
        }
    }
    
    func gotoTransferDetailWithConfiguration(_ configuration: TransferDetailConfiguration) {
        self.transferDetailCoordinator.goToDetail(with: configuration)
    }
}

extension ScheduledTransfersCoordinator {
    func showComingSoonToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    func showGenericError() {
        self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesEngine)
    }
}

extension ScheduledTransfersCoordinator: GenericErrorDialogPresentationCapable {
    var associatedGenericErrorDialogView: UIViewController {
        navigationController?.topViewController ?? UIViewController()
    }
}
