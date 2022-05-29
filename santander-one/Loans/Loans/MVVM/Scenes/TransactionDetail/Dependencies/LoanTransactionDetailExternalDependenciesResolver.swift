import UI
import CoreFoundationLib
import Foundation
import CoreDomain

public protocol LoanTransactionDetailExternalDependenciesResolver {
    func resolve() -> DependenciesResolver
    func resolve() -> LoanReactiveRepository
    func resolve() -> UINavigationController
    func resolve() -> NavigationBarItemBuilder
    func resolve() -> AccountNumberFormatterProtocol
    func resolve() -> SharedHandler
    func resolve() -> GetLoanTransactionDetailConfigurationUseCase
    func resolve() -> GetLoanTransactionDetailActionUseCase
    func resolve() -> GetLoanPDFInfoUseCase
    func resolve() -> GetLoanDetailUsecase
    func resolve() -> TrackerManager
    func loanTransactionDetailCoordinator() -> BindableCoordinator
    func loanTransactionDetailActionsCoordinator() -> BindableCoordinator
    func loanRepaymentCoordinator() -> BindableCoordinator
    func loanDetailCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
}

public extension LoanTransactionDetailExternalDependenciesResolver {
    func loanTransactionDetailCoordinator() -> BindableCoordinator {
        return DefaultLoanTransactionDetailCoordinator(dependencies: self, navigationController: resolve())
    }
}
