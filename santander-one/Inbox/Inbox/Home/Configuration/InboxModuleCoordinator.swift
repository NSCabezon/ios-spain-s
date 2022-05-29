import CoreFoundationLib
import UI

public class InboxModuleCoordinator: ModuleSectionedCoordinator {
    public weak var navigationController: UINavigationController?
    let coordinator: InboxHomeModuleCoordinator

    public enum InboxSection: CaseIterable {
        case home
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.coordinator = InboxHomeModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
    }
    
    public func start(_ section: InboxSection) {
        switch section {
        case .home:
             return self.coordinator.start()
        }
    }
}
