//
//  BillEmittersPaymentFinishingCoordinator.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/14/20.
//

import Foundation

final class BillEmittersPaymentFinishingCoordinator {
    private weak var navigationController: UINavigationController?
    
    init(navigatorController: UINavigationController?) {
        self.navigationController = navigatorController
    }
}

extension BillEmittersPaymentFinishingCoordinator: BillEmittersPaymentFinishingCoordinatorProtocol {
    func goToGlobalPosition() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func gotoBillsHome() {
        let controller = self.navigationController?
            .viewControllers
            .first(where: { $0 is BillHomeViewController})
        guard let billHomeViewController = controller else {
            return self.goToGlobalPosition()
        }
        self.navigationController?.popToViewController(billHomeViewController, animated: true)
    }
}
