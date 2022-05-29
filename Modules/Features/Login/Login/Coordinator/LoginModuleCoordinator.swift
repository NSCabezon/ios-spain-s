import UI
import CoreFoundationLib
import LoginCommon

public class LoginModuleCoordinator: ModuleSectionedCoordinator {
    public weak var navigationController: UINavigationController?
    let coordinatorQuickBalance: QuickBalanceCoordinator
    private let unrememberdLoginCoordinator: UnrememberedLoginCoordinator
    private let loginRememberedCoordinator: LoginRememberedCoordinator
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.coordinatorQuickBalance = QuickBalanceCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
        self.unrememberdLoginCoordinator = UnrememberedLoginCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
        self.loginRememberedCoordinator = LoginRememberedCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
    }
}

extension LoginModuleCoordinator: LoginModuleCoordinatorProtocol {
    public func start(_ section: LoginSection) {
        switch section {
        case .unrememberedLogin:
            self.unrememberdLoginCoordinator.start()
        case .loginRemembered:
            self.loginRememberedCoordinator.start()
        case .quickBalance:
            return self.coordinatorQuickBalance.start()
        }
    }
}
