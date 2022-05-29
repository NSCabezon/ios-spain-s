//
//  LoanRepaymentCoordinator.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/20/21.
//
import UI
import CoreFoundationLib
import CoreDomain
import Operative
import Foundation

final class DefaultLoanRepaymentCoordinator: BindableCoordinator {
    var onFinish: (() -> Void)?
    var dataBinding: DataBinding = DataBindingObject()
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    private var externalDependencies: LoanRepaymentExternalDependenciesResolver
    private lazy var legacyDependenciesResolver: DependenciesDefault = {
        DependenciesDefault(father: externalDependencies.resolve())
    }()
    
    init(dependencies: LoanRepaymentExternalDependenciesResolver, navigationController: UINavigationController) {
        self.externalDependencies = dependencies
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    func start() {
        guard let loanRepresentable: LoanRepresentable = dataBinding.get() else {
            return
        }
        let loanEntity = LoanEntity(loanRepresentable)
        self.goToLoanPartialAmortization(loan: loanEntity)
    }
}

extension DefaultLoanRepaymentCoordinator: OperativeLauncherHandler {
    var dependenciesResolver: DependenciesResolver {
        return legacyDependenciesResolver
    }
    
    public var operativeNavigationController: UINavigationController? {
        return self.navigationController
    }
    
    public func showOperativeLoading(completion: @escaping () -> Void) {
        self.showLoading(completion: completion)
    }
    
    public func hideOperativeLoading(completion: @escaping () -> Void) {
        self.dismissLoading(completion: completion)
    }
    
    public func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        let operativeCoordinatorLauncher = legacyDependenciesResolver
            .resolve(for: OperativeCoordinatorLauncher.self)
            .showOperativeAlertError(keyTitle: keyTitle, keyDesc: keyDesc, completion: completion)
    }
}

extension DefaultLoanRepaymentCoordinator: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        self.navigationController?.topViewController ?? UIViewController()
    }
}

private extension DefaultLoanRepaymentCoordinator {
    func goToLoanPartialAmortization(loan: LoanEntity) {
        let operative = LoanPartialAmortizationOperative(dependencies: legacyDependenciesResolver)
        let operativeData = LoanPartialAmortizationOperativeData(loan.dto)
        self.go(to: operative, handler: self, operativeData: operativeData)
    }
    
    private func setupDependencies() {
        legacyDependenciesResolver.register(for: LoanPartialAmortizationFinishingCoordinatorProtocol.self) { _ in
            return LoanPartialAmortizationFinishingCoordinator(navigationController: self.operativeNavigationController)
        }
    }
}

extension DefaultLoanRepaymentCoordinator: OperativeContainerLauncher {}
