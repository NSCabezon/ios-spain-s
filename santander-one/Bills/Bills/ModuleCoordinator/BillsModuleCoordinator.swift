import CoreFoundationLib
import UI
import CoreDomain

public class BillsModuleCoordinator: ModuleSectionedCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesResolver: DependenciesResolver
    var coordinator: BillHomeModuleCoordinator {
        return BillHomeModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
    }
    let directDebitCoordinator: DirectDebitCoordinator
    let paymentCoordinator: PaymentCoordinator
    
    public enum BillsSection: CaseIterable {
        case home
        case directDebit
        case payment
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesResolver = dependenciesResolver
        self.directDebitCoordinator = DirectDebitCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
        self.paymentCoordinator = PaymentCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
    }
    
    public func start(_ section: BillsSection) {
        switch section {
        case .home:
             return self.coordinator.start()
        case .directDebit:
            return self.directDebitCoordinator.start()
        case .payment:
            return self.paymentCoordinator.start()
        }
    }
    
    public func goToFutureBill(_ bill: AccountFutureBillRepresentable, in bills: [AccountFutureBillRepresentable], for entity: AccountEntity) {
        self.coordinator.goToFutureBill(bill, in: bills, for: entity)
    }
}
