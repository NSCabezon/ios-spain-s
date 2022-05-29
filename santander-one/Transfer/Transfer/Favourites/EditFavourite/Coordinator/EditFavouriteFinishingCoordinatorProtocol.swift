//
//  EditFavouriteFinishingCoordinatorProtocol.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 19/07/2021.
//

import Foundation
import Operative

protocol EditFavouriteFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToNewSendMoney()
    func goToGlobalPosition()
}

extension EditFavouriteFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption = self.getFinishingOption(for: operative) else {
            self.gotoCoordinatorSourceController(coordinator)
            return
        }
        switch finishingOption {
        case .home:
            self.goToNewSendMoney()
        case .globalPosition:
            self.goToGlobalPosition()
        }
    }
}

private extension EditFavouriteFinishingCoordinatorProtocol {
    func getFinishingOption(for operative: Operative) -> EditFavouriteOperative.FinishingOption? {
        guard let operative = operative as? EditFavouriteOperative else { return nil }
        guard let finishingOption: EditFavouriteOperative.FinishingOption = operative.container?.getOptional() else { return nil }
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
