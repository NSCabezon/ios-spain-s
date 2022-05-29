import Foundation
import Operative
import UI
import CoreFoundationLib

protocol DeleteFavouriteFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToNewSendMoney()
    func goToGlobalPosition()
    func dismissOperative()
}

extension DeleteFavouriteFinishingCoordinatorProtocol {
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
        case .operativeFinished:
            self.dismissOperative()
        }
    }
}

private extension DeleteFavouriteFinishingCoordinatorProtocol {
    func getFinishingOption(for operative: Operative) -> DeleteFavouriteOperative.FinishingOption? {
        guard let operative = operative as? DeleteFavouriteOperative else { return nil }
        guard let finishingOption: DeleteFavouriteOperative.FinishingOption = operative.container?.getOptional() else { return nil }
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
