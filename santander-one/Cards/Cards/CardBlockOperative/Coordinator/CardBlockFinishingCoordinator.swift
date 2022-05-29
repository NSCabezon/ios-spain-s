//
//  CardBlockFinishingCoordinator.swift
//  Cards
//
//  Created by Laura González on 27/05/2021.
//

import Operative
import CoreFoundationLib

enum CardBlockFinishingOption {
    case cardsHome
    case globalPosition
}

protocol CardBlockFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func back()
}

final class CardBlockFinishingCoordinator {
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

private extension CardBlockFinishingCoordinator {
    func goToGlobalPosition() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func goToCardsHome() {
        let controller = self.navigationController?
            .viewControllers
            .first(where: { $0 is CardsHomeViewController})
        guard let cardsHomeViewController = controller else {
            return self.goToGlobalPosition()
        }
        self.navigationController?.popToViewController(cardsHomeViewController, animated: true)
    }
}

extension CardBlockFinishingCoordinator: CardBlockFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption: CardBlockFinishingOption = operative.container?.getOptional() else {
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
        case .cardsHome:
            self.goToCardsHome()
        }
    }
    
    func back() {
        self.goToCardsHome()
    }
}
