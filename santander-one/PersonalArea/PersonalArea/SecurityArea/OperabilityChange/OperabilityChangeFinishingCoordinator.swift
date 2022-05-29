//
//  OperabilityChangeFinishingCoordinator.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 22/05/2020.
//

import Operative

class OperabilityChangeFinishingCoordinator: OperabilityChangeFinishingCoordinatorProtocol {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func goToGlobalPosition() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

public protocol OperabilityChangeFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToGlobalPosition()
}

public extension OperabilityChangeFinishingCoordinatorProtocol {
    
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption: OperabilityChangeOperative.FinishingOption = operative.container?.getOptional() else {
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
        }
    }
}
