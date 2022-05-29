//
//  BillEmittersPaymentFinishingCoordinatorProtocol.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/14/20.
//

import Foundation
import Operative

protocol BillEmittersPaymentFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToGlobalPosition()
    func gotoBillsHome()
}

extension BillEmittersPaymentFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption = self.getFinishingOption(for: operative) else {
            self.gotoCoordinatorSourceController(coordinator)
            return
        }
        switch finishingOption {
        case .globalPosition:
            self.goToGlobalPosition()
        case .billsHome:
            self.gotoBillsHome()
        }
    }
    
    private func getFinishingOption(for operative: Operative) -> BillEmittersPaymentOperative.FinishingOption? {
        guard let operative = operative as? BillEmittersPaymentOperative else { return nil }
        guard let finishingOption: BillEmittersPaymentOperative.FinishingOption = operative.container?.getOptional() else { return nil }
        return finishingOption
    }
    
    private func gotoCoordinatorSourceController(_ coordinator: OperativeContainerCoordinatorProtocol) {
        guard let controller = coordinator.sourceView else {
            coordinator.navigationController?.popToRootViewController(animated: true)
            return
        }
        coordinator.navigationController?.popToViewController(controller, animated: true)
    }
}
