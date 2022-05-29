import Foundation
import UI
import CoreFoundationLib

final class ChangePasswordFinishingCoordinator {
    private weak var navigationController: UINavigationController?
    
    init(navigatorController: UINavigationController?) {
        self.navigationController = navigatorController
    }
}

extension ChangePasswordFinishingCoordinator: ChangePasswordFinishingCoordinatorProtocol {
    func goToSecurity() {
        self.navigationController?.popViewController(animated: true)
        TopAlertController.setup(TopAlertView.self).showAlert(title: localized("keyChange_alert_title_success"), localized("keyChange_alert_text_success"), alertType: .info, position: .bottom)
    }
}
