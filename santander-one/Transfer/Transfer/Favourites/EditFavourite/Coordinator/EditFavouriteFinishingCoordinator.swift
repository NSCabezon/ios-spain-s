//
//  EditFavouriteFinishingCoordinator.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 19/07/2021.
//

import Foundation
import CoreFoundationLib

final class EditFavouriteFinishingCoordinator {
    private weak var navigationController: UINavigationController?
    
    init(navigatorController: UINavigationController?) {
        self.navigationController = navigatorController
    }
}

extension EditFavouriteFinishingCoordinator: EditFavouriteFinishingCoordinatorProtocol {
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
