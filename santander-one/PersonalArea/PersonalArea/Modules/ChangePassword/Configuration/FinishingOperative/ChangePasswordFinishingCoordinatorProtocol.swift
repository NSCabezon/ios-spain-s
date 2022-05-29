import Foundation
import Operative
import UI
import CoreFoundationLib

protocol ChangePasswordFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToSecurity()
}

extension ChangePasswordFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption = self.getFinishingOption(for: operative) else {
            self.gotoCoordinatorSourceController(coordinator)
            return
        }
        switch finishingOption {
        case .security:
            self.goToSecurity()
        }
    }
}

private extension ChangePasswordFinishingCoordinatorProtocol {
    func getFinishingOption(for operative: Operative) -> ChangePasswordOperative.FinishingOption? {
        guard let operative = operative as? ChangePasswordOperative else { return nil }
        guard let finishingOption: ChangePasswordOperative.FinishingOption = operative.container?.getOptional() else { return nil }
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
