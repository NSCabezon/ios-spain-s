import Transfer
import Bills
import CoreFoundationLib

protocol AccountProfileNavigatorProtocol: OperativesNavigatorProtocol {
    func goToTransfers(account: AccountEntity?)
    func goToBillsAndTaxes(account: AccountEntity?)
    func goToHistoricalEmittedTransfer(account: AccountEntity?)
}

class AccountProfileNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    let billCoordinator: BillsModuleCoordinator
    private let historicalEmittedTransferCoordinator: HistoricalTransferCoordinator

    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        let navigationController = drawer.currentRootViewController as? NavigationController
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        
        self.billCoordinator = BillsModuleCoordinator(
            dependenciesResolver: presenterProvider.dependenciesEngine,
            navigationController: navigationController ?? UINavigationController())
        
        self.historicalEmittedTransferCoordinator = HistoricalTransferCoordinator(
            dependenciesResolver: presenterProvider.dependenciesEngine,
            navigationController: navigationController ?? UINavigationController())
    }
}

extension AccountProfileNavigator: AccountProfileNavigatorProtocol {
    func goToTransfers(account: AccountEntity?) {
        launchTransferSection(.home, selectedAccount: account)
    }
    
    func goToBillsAndTaxes(account: AccountEntity?) {
        guard let accountDTO = account?.dto else { return }
        self.presenterProvider
            .dependenciesEngine
            .register(for: BillConfiguration.self) { _ in
            return BillConfiguration(account: AccountEntity(accountDTO))
        }
        self.presenterProvider
            .dependenciesEngine
            .register(for: BillHomeModuleCoordinatorDelegate.self) {_ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: BillsHomeCoordinatorNavigator.self)
        }
        self.presenterProvider
            .dependenciesEngine
            .register(for: DirectDebitCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: BillsHomeCoordinatorNavigator.self)
        }
        self.presenterProvider
            .dependenciesEngine
            .register(for: PaymentCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: BillsHomeCoordinatorNavigator.self)
        }
        self.billCoordinator.start(.home)
    }
    
    func goToHistoricalEmittedTransfer(account: AccountEntity?) {
        guard let accountEntity = account else { return }
        self.presenterProvider.dependenciesEngine.register(for: TransfersHomeConfiguration.self) { _ in
            return TransfersHomeConfiguration(selectedAccount: accountEntity, isScaForTransactionsEnabled: false)
        }
        self.presenterProvider.dependenciesEngine.register(for: TransferHomeModuleCoordinatorDelegate.self) {_ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: TransfersHomeCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: ContactDetailCoordinatorDelegate.self) {_ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: TransfersHomeCoordinatorNavigator.self)
        }
        self.historicalEmittedTransferCoordinator.start()
    }
}
