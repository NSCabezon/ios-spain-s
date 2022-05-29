import Foundation
import UI
import CoreFoundationLib

final class NewFavouriteFinishingCoordinator {
    private weak var navigationController: UINavigationController?
    
    init(navigatorController: UINavigationController?) {
        self.navigationController = navigatorController
    }
}

extension NewFavouriteFinishingCoordinator: NewFavouriteFinishingCoordinatorProtocol {
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
