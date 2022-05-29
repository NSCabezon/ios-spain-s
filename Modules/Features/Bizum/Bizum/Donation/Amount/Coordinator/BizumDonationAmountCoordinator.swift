import UI
import CoreFoundationLib

protocol BizumDonationAmountCoordinatorProtocol {
    func goToAccountSelector(delegate: BizumSendMoneyAccountSelectorCoordinatorDelegate)
}

final class BizumDonationAmountCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let accountSelectorCoordinator: BizumSendMoneyAccountSelectorCoordinator

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.accountSelectorCoordinator = BizumSendMoneyAccountSelectorCoordinator(navigationController: navigationController,
                                                                                   dependenciesResolver: self.dependenciesEngine)
    }
}

extension BizumDonationAmountCoordinator: BizumDonationAmountCoordinatorProtocol {
    func goToAccountSelector(delegate: BizumSendMoneyAccountSelectorCoordinatorDelegate) {
        self.dependenciesEngine.register(for: BizumSendMoneyAccountSelectorCoordinatorDelegate.self) { _ in
            return delegate
        }
        self.accountSelectorCoordinator.start()
    }
}
