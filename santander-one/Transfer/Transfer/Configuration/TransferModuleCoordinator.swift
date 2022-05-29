import TransferOperatives
import CoreFoundationLib
import UI
import TransferOperatives

public final class TransferModuleCoordinator: ModuleSectionedCoordinator {
    public weak var navigationController: UINavigationController?
    let coordinator: TransferHomeModuleCoordinator
    private var historicalCoordinator: HistoricalTransferCoordinator
    
    public enum TransferSection: CaseIterable {
        case home
        case internalTransfer
        case newShipment
        case historical
    }
    
    public init(transferExternalResolver: TransferExternalDependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.coordinator = TransferHomeModuleCoordinator(transferExternalDependencies: transferExternalResolver, navigationController: navigationController)
        self.historicalCoordinator = HistoricalTransferCoordinator(dependenciesResolver: transferExternalResolver.resolve(), navigationController: navigationController)
    }
    
    public func start(_ section: TransferSection) {
        switch section {
        case .home:
            self.coordinator.start()
        case .internalTransfer:
            self.coordinator.startOnInternalTransfer()
        case .newShipment:
            self.coordinator.goToNewShipment(for: nil)
        case .historical:
            self.historicalCoordinator.start()
        }
    }
}
