//
//  BizumGoToHomeFinishingCoordinator.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 16/12/20.
//

import Operative

final class BizumGoToHomeFinishingCoordinator: BizumFinishingCoordinatorProtocol {
    
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption: BizumFinishingOption = operative.container?.getOptional() else {
            return self.goToHome()
        }
        switch finishingOption {
        case .globalPosition:
            self.goToGlobalPosition()
        case .home:
            self.goToHome()
        }
    }
}
