import Foundation
import Operative
import UI
import CoreFoundationLib

protocol NewFavouriteFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToNewSendMoney()
    func goToGlobalPosition()
}

extension NewFavouriteFinishingCoordinatorProtocol {
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

private extension NewFavouriteFinishingCoordinatorProtocol {
    func getFinishingOption(for operative: Operative) -> NewFavouriteOperative.FinishingOption? {
        guard let operative = operative as? NewFavouriteOperative else { return nil }
        guard let finishingOption: NewFavouriteOperative.FinishingOption = operative.container?.getOptional() else { return nil }
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
