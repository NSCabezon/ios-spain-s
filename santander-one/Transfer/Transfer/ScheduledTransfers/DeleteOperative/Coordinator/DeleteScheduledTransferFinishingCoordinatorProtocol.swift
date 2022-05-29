//
//  DeleteScheduledTransferFinishingCoordinatorProtocol.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 21/7/21.
//

import Operative
import UI
import CoreFoundationLib

protocol DeleteScheduledTransferFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToNewSendMoney()
    func goToGlobalPosition()
}

extension DeleteScheduledTransferFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption = self.getFinishingOption(for: operative) else {
            self.gotoCoordinatorSourceController(coordinator)
            return
        }
        switch finishingOption {
        case .home, .operativeFinished:
            self.goToNewSendMoney()
        case .globalPosition:
            self.goToGlobalPosition()
        }
    }
}

private extension DeleteScheduledTransferFinishingCoordinatorProtocol {
    func getFinishingOption(for operative: Operative) -> DeleteScheduledTransferOperative.FinishingOption? {
        guard let operative = operative as? DeleteScheduledTransferOperative else { return nil }
        guard let finishingOption: DeleteScheduledTransferOperative.FinishingOption = operative.container?.getOptional() else { return nil }
        return finishingOption
    }
    
    func gotoCoordinatorSourceController(_ coordinator: OperativeContainerCoordinatorProtocol) {
        guard let controller = coordinator.sourceView else {
            coordinator.navigationController?.popToRootViewController(animated: true)
            return
        }
        coordinator.navigationController?.popToViewController(controller, animated: true)
    }
}
