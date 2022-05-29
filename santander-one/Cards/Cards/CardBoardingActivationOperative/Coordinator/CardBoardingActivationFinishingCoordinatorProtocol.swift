//
//  CardBoardingActivationFinishingCoordinatorProtocol.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 06/10/2020.
//

import Foundation
import Operative
import CoreFoundationLib

protocol CardBoardingActivationFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToGlobalPosition()
    func goToCardBoarding(card: CardEntity)
    func goToCardHome(coordinator: OperativeContainerCoordinatorProtocol)
    func goToRecoverPin(card: CardEntity, coordinator: OperativeContainerCoordinatorProtocol)
}

extension CardBoardingActivationFinishingCoordinatorProtocol {
    
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption = self.getFinishingOption(for: operative) else {
            self.gotoCoordinatorSourceController(coordinator)
            return
        }
        switch finishingOption {
        case .globalPosition:
            self.goToGlobalPosition()
        case .goToCardBoarding:
            guard let card = getCard(operative: operative) else {
                self.goToGlobalPosition()
                return
            }
            self.goToCardBoarding(card: card)
        case .goToCardHome:
            self.goToCardHome(coordinator: coordinator)
        case .goToReceivePin:
            guard let card = getCard(operative: operative) else {
                self.goToGlobalPosition()
                return
            }
            self.goToRecoverPin(card: card, coordinator: coordinator)
        }
    }
}

private extension CardBoardingActivationFinishingCoordinatorProtocol {
    
    func getCard(operative: Operative) -> CardEntity? {
        guard let operativeData: CardBoardingActivationOperativeData = operative.container?.get() else {
            return nil
        }
        return operativeData.selectedCard
    }
    
    func getFinishingOption(for operative: Operative) -> CardBoardingActivationOperative.FinishingOption? {
        guard let operative = operative as? CardBoardingActivationOperative else { return nil }
        guard let finishingOption: CardBoardingActivationOperative.FinishingOption = operative.container?.getOptional() else { return nil }
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
