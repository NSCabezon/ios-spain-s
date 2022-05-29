import CoreFoundationLib
import UI

public protocol BizumModuleCoordinatorProtocol {
    func start(_ section: BizumSection)
}

public enum BizumSection: CaseIterable {
    case home
}

public class BizumModuleCoordinator: ModuleSectionedCoordinator {
    public weak var navigationController: UINavigationController?
    let coordinator: BizumHomeModuleCoordinator

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.coordinator = BizumHomeModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
    }
}

extension BizumModuleCoordinator: BizumModuleCoordinatorProtocol {
    public func start(_ section: BizumSection) {
        switch section {
        case .home:
             return self.coordinator.start()
        }
    }
}
