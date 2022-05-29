//
//  InternalTransferFinishingCoordinator.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 15/01/2020.
//

import TransferOperatives
import CoreFoundationLib
import Operative

class InternalTransferFinishingCoordinator: InternalTransferFinishingCoordinatorProtocol {
    private weak var navigationController: UINavigationController?
    private let transferExternalDependencies: OneTransferHomeExternalDependenciesResolver
    
    init(transferExternalDependencies: OneTransferHomeExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.transferExternalDependencies = transferExternalDependencies
    }
    
    func goToGlobalPosition() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func goToSendMoney() {
        guard let transferHomeViewController = self.navigationController?.viewControllers.first(where: {
            $0 is TransferHomeViewController
        })
        else {
            return self.popToRootViewController(animated: false, completion: goToSendMoneyIfNotCreated)
        }
        self.navigationController?.popToViewController(transferHomeViewController, animated: true)
    }
}

private extension InternalTransferFinishingCoordinator {
    func goToSendMoneyIfNotCreated() {
        guard let navigationController = self.navigationController else { return self.goToGlobalPosition() }
        let dependencies = DependenciesDefault(father: transferExternalDependencies.resolve())
        dependencies.register(for: TransfersHomeConfiguration.self) { _ in
            return TransfersHomeConfiguration(selectedAccount: nil, isScaForTransactionsEnabled: false)
        }
        let coordinator = TransferHomeModuleCoordinator(
            transferExternalDependencies: transferExternalDependencies,
            navigationController: navigationController
        )
        coordinator.start()
    }
    
    func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        self.navigationController?.popToRootViewController(animated: animated)
        guard let transition = self.navigationController?.transitionCoordinator else {
            completion()
            return
        }
        transition.animate(alongsideTransition: nil) { _ in
            completion()
        }
    }
}

public protocol InternalTransferFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToGlobalPosition()
    func goToSendMoney()
}

public extension InternalTransferFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let operative = operative as? InternalTransferOperative, let finishingOption: InternalTransferOperative.FinishingOption = operative.container?.getOptional() else {
            if let sourceView = coordinator.sourceView {
                coordinator.navigationController?.popToViewController(sourceView, animated: true)
            } else {
                coordinator.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        switch finishingOption {
        case .globalPosition:
            self.goToGlobalPosition()
        case .sendMoney:
            self.goToSendMoney()
        }
    }
}
