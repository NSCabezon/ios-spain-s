import CoreFoundationLib
import UI

public class GlobalSearchModuleCoordinator: ModuleSectionedCoordinator {
    public weak var navigationController: UINavigationController?
    let coordinator: GlobalSearchMainModuleCoordinator

    public enum GlobalSearchSection: CaseIterable {
        case main
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.coordinator = GlobalSearchMainModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
    }
    
    public func start(_ section: GlobalSearchSection) {
        switch section {
        case .main:
             return self.coordinator.start()
        }
    }
}
