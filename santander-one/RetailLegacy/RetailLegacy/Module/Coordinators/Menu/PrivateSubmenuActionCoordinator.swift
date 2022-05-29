import UI
import CoreFoundationLib
import CoreDomain

final class PrivateSubMenuActionCoordinator: BindableCoordinator {
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
        guard let action: PrivateMenuProductHome = dataBinding.get() else { return }
        legacyDependencies
            .resolve(for: NavigatorProvider.self)
            .privateHomeNavigator
            .present(selectedProduct: nil, productHome: action)
    }
}
