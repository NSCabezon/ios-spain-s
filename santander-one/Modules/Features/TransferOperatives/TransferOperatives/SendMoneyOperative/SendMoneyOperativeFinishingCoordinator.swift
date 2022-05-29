//
//  SendMoneyOperativeFinishingCoordinator.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import Operative
import CoreFoundationLib

protocol SendMoneyOperativeFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func goToGlobalPosition()
    func goToSendMoney()
}

final class SendMoneyOperativeFinishingCoordinator: SendMoneyOperativeFinishingCoordinatorProtocol {

    private weak var navigationController: UINavigationController?
    private let dependenciesResolver: DependenciesResolver

    init(navigationController: UINavigationController?, dependenciesResolver: DependenciesResolver) {
        self.navigationController = navigationController
        self.dependenciesResolver = dependenciesResolver
    }

    func goToGlobalPosition() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    func goToSendMoney() {
        guard let transferHomeViewController = self.navigationController?.viewControllers.first(where: {
            $0 is TransferHomeView
        }) else {
            self.navigationController?.popToRootViewController(animated: true)
            self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)?.goToSendMoney()
            return
        }
        self.navigationController?.popToViewController(transferHomeViewController, animated: true)
    }
}

extension SendMoneyOperativeFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let operative = operative as? SendMoneyOperative,
              let finishingOption: SendMoneyOperative.FinishingOption = operative.container?.getOptional()
        else {
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
        case .sendMoney:
            self.goToSendMoney()
        }
    }
}

public protocol TransferHomeView: UIViewController {}
