import CoreFoundationLib
import Transfer
import UIKit

protocol TransferModuleCoordinatorLauncher {
    var navigatorProvider: NavigatorProvider { get }
    var navigationController: UINavigationController { get }
    var transferDependenciesEngine: DependenciesResolver & DependenciesInjector { get }
    var transferExternalResolver: TransferExternalDependenciesResolver { get }
    func launchTransferSection(_ section: TransferModuleCoordinator.TransferSection, selectedAccount: AccountEntity?)
    func launchTransferSection(_ section: TransferModuleCoordinator.TransferSection)
}

extension TransferModuleCoordinatorLauncher {
    func launchTransferSection(_ section: TransferModuleCoordinator.TransferSection) {
        launchTransferSection(section, selectedAccount: nil)
    }
    
    func launchTransferSection(_ section: TransferModuleCoordinator.TransferSection, selectedAccount: AccountEntity?) {
        let transferCoordinator = TransferModuleCoordinator(
            transferExternalResolver: transferExternalResolver,
            navigationController: navigationController
        )
        transferDependenciesEngine.register(for: TransfersHomeConfiguration.self) { _ in
            return TransfersHomeConfiguration(selectedAccount: selectedAccount, isScaForTransactionsEnabled: false)
        }
        transferDependenciesEngine.register(for: TransferHomeModuleCoordinatorDelegate.self) { _ in
            return navigatorProvider.getModuleCoordinator(type: TransfersHomeCoordinatorNavigator.self)
        }
        transferDependenciesEngine.register(for: ScheduledTransfersCoordinatorDelegate.self) { _ in
            return navigatorProvider.getModuleCoordinator(type: TransfersHomeCoordinatorNavigator.self)
        }
        transferDependenciesEngine.register(for: ContactDetailCoordinatorDelegate.self) { _ in
            return navigatorProvider.getModuleCoordinator(type: TransfersHomeCoordinatorNavigator.self)
        }
        transferCoordinator.start(section)
    }
}
