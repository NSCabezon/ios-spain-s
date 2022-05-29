//
//  CardOnOffFinishingCoordinator.swift
//  Account
//
//  Created by Iván Estévez Nieto on 30/8/21.
//

import Foundation
import Operative
import CoreFoundationLib

enum CardOnOffFinishingOption {
    case cardsHome
    case globalPosition
    case operativeFinished
}

protocol CardOnOffFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func back()
}

final class CardOnOffFinishingCoordinator {
    private weak var navigationController: UINavigationController?
    private let dependenciesResolver: DependenciesDefault
    private let externalDependencies: CardExternalDependenciesResolver
    
    init(navigationController: UINavigationController?, dependenciesResolver: DependenciesDefault, externalDependencies: CardExternalDependenciesResolver) {
        self.externalDependencies = externalDependencies
        self.navigationController = navigationController
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension CardOnOffFinishingCoordinator {
    func goToGlobalPosition() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func goToCardsHome() {
        let controller = self.navigationController?
            .viewControllers
            .first(where: { $0 is CardsHomeViewController})
        guard let cardsHomeViewController = controller else {
            return self.createCardsHome()
        }
        self.navigationController?.popToViewController(cardsHomeViewController, animated: true)
    }
    
    func createCardsHome() {
        guard let navigationController = self.navigationController else { return }
        dependenciesResolver.register(for: CardsHomeConfiguration.self) { _ in
            return CardsHomeConfiguration(selectedCard: nil)
        }
        let cardCoordinator = CardsModuleCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: navigationController,
            externalDependencies: externalDependencies
        )
        navigationController.popToRootViewController(animated: false) {
            cardCoordinator.start(.home)
        }
    }
    
    func reloadGlobalPosition() {
        let globalPositionReloader = self.dependenciesResolver.resolve(for: GlobalPositionReloader.self)
        globalPositionReloader.reloadGlobalPosition()
    }
}

extension CardOnOffFinishingCoordinator: CardOnOffFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption: CardOnOffFinishingOption = operative.container?.getOptional() else {
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
        case .operativeFinished:
            self.dismissOperative()
        }
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
        self.reloadGlobalPosition()
    }

    func dismissOperative() {
        let viewControllerArray = self.navigationController?.viewControllers.filter({ !($0 is OperativeView)}) ?? []
        guard let lastviewController = viewControllerArray.last else {
            self.goToGlobalPosition()
            return
        }
        self.navigationController?.popToViewController(lastviewController, animated: true)
    }
}
