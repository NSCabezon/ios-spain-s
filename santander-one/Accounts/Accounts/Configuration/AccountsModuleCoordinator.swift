import CoreFoundationLib
import UI

public final class AccountsModuleCoordinator: ModuleSectionedCoordinator {
    
    public let coordinator: AccountsHomeCoordinator
    public weak var navigationController: UINavigationController?
    private let accountTransactionDetailCoordinator: AccountTransactionDetailCoordinator

    public enum AccountsSection: CaseIterable {
        case home
        case detail
        case detailWithOutAssociated
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.coordinator = AccountsHomeCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
        self.accountTransactionDetailCoordinator = AccountTransactionDetailCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
    }
    
    public func start(_ section: AccountsSection) {
        switch section {
        case .home:
            self.coordinator.start()
        case .detail:
            self.accountTransactionDetailCoordinator.start()
        case .detailWithOutAssociated:
            self.accountTransactionDetailCoordinator.start(section)
        }
    }
}
