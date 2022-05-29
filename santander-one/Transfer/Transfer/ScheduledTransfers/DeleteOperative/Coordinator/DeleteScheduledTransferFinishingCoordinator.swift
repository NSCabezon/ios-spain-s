//
//  DeleteScheduledTransferFinishingCoordinator.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 21/7/21.
//

import Foundation
import UI
import CoreFoundationLib

final class DeleteScheduledTransferFinishingCoordinator {
    private weak var navigationController: UINavigationController?
    
    init(navigatorController: UINavigationController?) {
        self.navigationController = navigatorController
    }
}

extension DeleteScheduledTransferFinishingCoordinator: DeleteScheduledTransferFinishingCoordinatorProtocol {
    func goToNewSendMoney() {
        guard let transferHomeViewController = self.navigationController?.viewControllers.first(where: {
            $0 is TransferHomeViewController
        }) else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.navigationController?.popToViewController(transferHomeViewController, animated: true)
    }
    
    func goToGlobalPosition() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
