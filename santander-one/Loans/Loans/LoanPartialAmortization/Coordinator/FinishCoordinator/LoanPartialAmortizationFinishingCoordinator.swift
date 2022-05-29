//
//  LoanPartialAmortizationFinishingCoordinator.swift
//  Loans
//
//  Created by Andres Aguirre Juarez on 22/9/21.
//

import Operative
import CoreFoundationLib

enum LoanPartialAmortizationFinishingOption {
    case loansHome
    case globalPosition
}

protocol LoanPartialAmortizationFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    func back()
}

final class LoanPartialAmortizationFinishingCoordinator {
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

private extension LoanPartialAmortizationFinishingCoordinator {
    func goToGlobalPosition() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func goToLoansHome() {
        let controller = self.navigationController?
            .viewControllers
            .first(where: { $0 is LoanHomeViewController})
        guard let loansHomeViewController = controller else {
            return self.goToGlobalPosition()
        }
        self.navigationController?.popToViewController(loansHomeViewController, animated: true)
    }
}

extension LoanPartialAmortizationFinishingCoordinator: LoanPartialAmortizationFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption: LoanPartialAmortizationFinishingOption = operative.container?.getOptional() else {
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
        case .loansHome:
            self.goToLoansHome()
        }
    }
    
    func back() {
        self.goToLoansHome()
    }
}
