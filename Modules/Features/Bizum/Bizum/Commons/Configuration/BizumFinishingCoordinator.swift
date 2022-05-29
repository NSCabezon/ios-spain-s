//
//  BizumSendOrRequestMoneyFinishingCoordinator.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 20/11/2020.
//

import Foundation
import Operative
import CoreFoundationLib

enum BizumFinishingOption {
    case home
    case globalPosition
}

final class BizumSendOrRequestMoneyFinishingCoordinator: BizumFinishingCoordinatorProtocol {
    
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension BizumFinishingCoordinatorProtocol {
    func goToGlobalPosition(_ navigationController: UINavigationController?) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func goToHome(_ navigationController: UINavigationController?) {
        let controller = navigationController?
            .viewControllers
            .first(where: { $0 is BizumHomeViewController})
        guard let bizumHomeViewController = controller else {
            return self.goToGlobalPosition()
        }
        navigationController?.popToViewController(bizumHomeViewController, animated: true)
    }
}

protocol BizumFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    var navigationController: UINavigationController? { get set }
    func goToGlobalPosition()
    func goToHome()
}

extension BizumFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption: BizumFinishingOption = operative.container?.getOptional() else {
            if let sourceView = coordinator.sourceView {
                coordinator.navigationController?.popToViewController(sourceView, animated: true)
            } else {
                coordinator.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        switch finishingOption {
        case .globalPosition:
            self.goToGlobalPosition()
        case .home:
            self.goToHome()
        }
    }
    
    func goToGlobalPosition() {
        if let baseMenuController = self.navigationController?.presentingViewController as? BaseMenuController,
            let navigationController = baseMenuController.currentRootViewController as? UINavigationController {
            navigationController.dismiss(animated: true, completion: {
                self.goToGlobalPosition(navigationController)
            })
        } else {
            self.goToGlobalPosition(self.navigationController)
        }
    }
    
    func goToHome() {
        if let baseMenuController = self.navigationController?.presentingViewController as? BaseMenuController,
            let navigationController = baseMenuController.currentRootViewController as? UINavigationController {
            navigationController.dismiss(animated: true, completion: {
                self.goToHome(navigationController)
            })
        } else {
            self.goToHome(self.navigationController)
        }
    }
}
