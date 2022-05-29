import CoreFoundationLib
import UI

public final class MenuModuleCoordinator: ModuleSectionedCoordinator {
    public weak var navigationController: UINavigationController?
    let coordinator: MenuMainModuleCoordinator
    let comingFeaturesCoordinator: ComingFeaturesCoordinator
    let financingCoordinator: FinancingCoordinator
    let oldAnalysisAreaCoordinator: OldAnalysisAreaCoordinator
    let cardFinanceableTransactions: CardFinanceableTransactionCoordinator
    let accountFinanceableTransactions: AccountFinanceableTransactionCoordinator
    private var atmDependencies: AtmDependencies
    var childCoordinators: [Coordinator] = []
    
    public enum MenuSection: CaseIterable {
        case main
        case comingFeatures
        case helpCenter
        case oldAnalysisArea
        case financing
        case cardFinanceableTransactions
        case accountFinanceableTransactions
        case atm
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.atmDependencies = AtmDependencies(
            dependenciesResolver: dependenciesResolver,
            navigationController: navigationController
        )
        self.coordinator = MenuMainModuleCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: navigationController
        )
        self.comingFeaturesCoordinator = ComingFeaturesCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: navigationController
        )
        self.financingCoordinator = FinancingCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: navigationController
        )
        self.oldAnalysisAreaCoordinator = OldAnalysisAreaCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: navigationController
        )
        self.cardFinanceableTransactions = CardFinanceableTransactionCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: navigationController
        )
        self.accountFinanceableTransactions = AccountFinanceableTransactionCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: navigationController
        )
    }
    
    public func start(_ section: MenuSection) {
        switch section {
        case .main:
            return self.coordinator.start()
        case .comingFeatures:
            return self.comingFeaturesCoordinator.start()
        case .helpCenter:
            return self.coordinator.startOnHelpCenter()
        case .oldAnalysisArea:
            return self.oldAnalysisAreaCoordinator.start()
        case .financing:
            return self.financingCoordinator.start()
        case .cardFinanceableTransactions:
            return self.cardFinanceableTransactions.start()
        case .atm:
            let coordinator = self.atmDependencies.publicMenuATMHomeCoordinator()
            coordinator.start()
            childCoordinators.append(coordinator)
        case .accountFinanceableTransactions:
            self.accountFinanceableTransactions.start()
        }
    }
}

/**
 Added cause, MenuModuleCoordinator is located in Menu Module and instantiated from RetailLegacy Module. We should use the MenuExternalDependenciesResolver but it can't, cause it can't be done without casting the RetailLegacyExternalDependenciesResolver to MenuExternalDependenciesResolver this is only done here to access to the atm coordinator and nothing else.
 **/

private extension MenuModuleCoordinator {
    struct AtmDependencies: ATMExternalDependenciesResolver {
        let dependenciesResolver: DependenciesResolver
        let navigationController: UINavigationController
        func resolve() -> UINavigationController {
            return navigationController
        }
        func resolve() -> DependenciesResolver {
            return dependenciesResolver
        }
    }
}
