import UI
import CoreFoundationLib
import CoreDomain

final class PrivateSubMenuVariableIncomeCoordinator: BindableCoordinator {
    var dataBinding: DataBinding = DataBindingObject()
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    private let dependencies: RetailLegacyPrivateMenuExternalDependenciesResolver
    private lazy var legacyDependencies: DependenciesResolver = dependencies.resolve()

    init(dependencies: RetailLegacyPrivateMenuExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    public func start() {
        legacyDependencies
            .resolve(for: NavigatorProvider.self)
            .privateHomeNavigator
            .goToVariableIncome()
    }
}
