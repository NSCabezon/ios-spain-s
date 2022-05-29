//
//  BizumSplitExpensesFinishingCoordinator.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 18/01/2021.
//

import Foundation
import Operative
import CoreFoundationLib
import UI

protocol BizumSplitExpensesFinishingCoordinatorProtocol: BizumFinishingCoordinatorProtocol {}

final class BizumSplitExpensesFinishingCoordinator: BizumSplitExpensesFinishingCoordinatorProtocol {
    weak var navigationController: UINavigationController?
    var dependenciesDefault: DependenciesDefault
    
    init(navigationController: UINavigationController?, dependeciesResolver: DependenciesResolver) {
        self.navigationController = navigationController
        self.dependenciesDefault = DependenciesDefault(father: dependeciesResolver)
    }
}

extension BizumSplitExpensesFinishingCoordinator {
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

private extension BizumSplitExpensesFinishingCoordinator {
    func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        self.navigationController?.popToRootViewController(animated: animated)
        guard let transition = self.navigationController?.transitionCoordinator else {
            completion()
            return
        }
        transition.animate(alongsideTransition: nil) { _ in
            completion()
        }
    }
    
    func goToHome(_ navigationController: UINavigationController?) {
        let controller = navigationController?
            .viewControllers
            .first(where: { $0 is BizumHomeViewController})
        guard let bizumHomeViewController = controller else {
            return self.popToRootViewController(animated: false, completion: executeBizumTypeUseCase)
        }
        navigationController?.popToViewController(bizumHomeViewController, animated: true)
    }
    
    func executeBizumTypeUseCase() {
        let input = BizumTypeUseCaseInput(type: .home)
        let useCase = BizumTypeUseCase(dependenciesResolver: self.dependenciesDefault)
        self.showLoading()
        Scenario(useCase: useCase, input: input).execute(on: self.dependenciesDefault.resolve())
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .native(let bizumCheckPayment):
                    self.goToBizumNative(bizumCheckPayment)
                default:
                    self.dismissLoading()
                }
            }
            .onError { _ in
                self.dismissLoading()
            }
    }
    
    func goToBizumNative(_ bizumCheckPayment: BizumCheckPaymentEntity) {
        self.dependenciesDefault.register(for: BizumCheckPaymentConfiguration.self) { _ in
            return BizumCheckPaymentConfiguration(bizumCheckPaymentEntity: bizumCheckPayment)
        }
        let coordinator = BizumHomeModuleCoordinator(dependenciesResolver: self.dependenciesDefault, navigationController: self.navigationController)
        self.dismissLoading {
            coordinator.start()
        }
    }
}

extension BizumSplitExpensesFinishingCoordinator: LoadingViewPresentationCapable {
    var associatedLoadingView: UIViewController {
        return self.navigationController?.topViewController ?? UIViewController()
    }
}
