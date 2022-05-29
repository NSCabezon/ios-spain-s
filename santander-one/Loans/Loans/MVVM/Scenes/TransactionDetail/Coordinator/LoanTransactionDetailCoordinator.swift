import Foundation
import UI
import CoreDomain
import CoreFoundationLib

protocol LoanTransactionDetailCoordinator: BindableCoordinator {
    func didSelectMenu()
    func didSelectAction(_ action: LoanTransactionDetailActionType, transaction: LoanTransactionRepresentable, loan: LoanRepresentable)
    func doShare(for shareable: Shareable)
    func didSelectShowLoanDetail(with loan: LoanRepresentable, detail: LoanDetailRepresentable)
    func didSelectLoanPartialAmortization(transaction: LoanTransactionRepresentable,
                                          loan: LoanRepresentable)
}

final class DefaultLoanTransactionDetailCoordinator: LoanTransactionDetailCoordinator {
    var onFinish: (() -> Void)?
    weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: LoanTransactionDetailExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: LoanTransactionDetailExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultLoanTransactionDetailCoordinator {
    func start() {
        guard dataBinding.contains(LoanRepresentable.self),
              dataBinding.contains(LoanTransactionRepresentable.self),
              dataBinding.contains([LoanTransactionRepresentable].self)
        else { return }
        navigationController?.blockingPushViewController(dependencies.resolve(), animated: true)
    }
    
    func didSelectMenu() {
        let menuCoordinator = dependencies.external.privateMenuCoordinator()
        menuCoordinator.start()
        append(child: menuCoordinator)
    }
    
    func didSelectAction(_ action: LoanTransactionDetailActionType,
                         transaction: LoanTransactionRepresentable,
                         loan: LoanRepresentable) {
        let coordinator = self.dependencies.external.loanTransactionDetailActionsCoordinator()
        coordinator
            .set(action)
            .set(transaction)
            .set(loan)
            .start()
        append(child: coordinator)
    }
    
    func doShare(for shareable: Shareable) {
        guard let controller = self.navigationController?.topViewController else { return }
        let sharedHandle: SharedHandler = self.dependencies.external.resolve()
        sharedHandle.doShare(for: shareable, in: controller)
    }
    
    func didSelectLoanPartialAmortization(transaction: LoanTransactionRepresentable,
                                          loan: LoanRepresentable) {
        let coordinator = self.externalDependencies.loanRepaymentCoordinator()
        coordinator
            .set(transaction)
            .set(loan)
            .start()
        append(child: coordinator)
    }
    
    func didSelectShowLoanDetail(with loan: LoanRepresentable, detail: LoanDetailRepresentable) {
        let coordinator = self.externalDependencies.loanDetailCoordinator()
        coordinator
            .set(loan)
            .set(detail)
            .start()
        append(child: coordinator)
    }
}

private extension DefaultLoanTransactionDetailCoordinator {
    struct Dependency: LoanTransactionDetailDependenciesResolver {
        let coreDependencies: CoreDependencies = DefaultCoreDependencies()
        let dependencies: LoanTransactionDetailExternalDependenciesResolver
        let coordinator: LoanTransactionDetailCoordinator
        let dataBinding = DataBindingObject()
        
        var external: LoanTransactionDetailExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> LoanTransactionDetailCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
        
        func resolve() -> CoreDependencies {
            return coreDependencies
        }
    }
}
