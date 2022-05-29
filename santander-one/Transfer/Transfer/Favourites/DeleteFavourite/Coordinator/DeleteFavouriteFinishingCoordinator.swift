import Foundation
import UI
import CoreFoundationLib
import Operative

final class DeleteFavouriteFinishingCoordinator {
    private weak var navigationController: UINavigationController?
    
    init(navigatorController: UINavigationController?) {
        self.navigationController = navigatorController
    }
}

extension DeleteFavouriteFinishingCoordinator: DeleteFavouriteFinishingCoordinatorProtocol {
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

extension DeleteFavouriteFinishingCoordinator {
    
    func dismissOperative() {
        let viewControllerArray = self.navigationController?.viewControllers.filter({ !($0 is OperativeView) && !($0 is ContactDetailViewController)}) ?? []
        guard let lastviewController = viewControllerArray.last else {
            self.goToGlobalPosition()
            return
        }
        self.navigationController?.popToViewController(lastviewController, animated: true)
    }
}
