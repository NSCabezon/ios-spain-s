
import Foundation
import CoreFoundationLib
import Loans

final class LoanDetailNavigator {
    private let presenterProvider: PresenterProvider
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver
    private let legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver, legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver) {
        self.legacyExternalDependenciesResolver = legacyExternalDependenciesResolver
        self.presenterProvider = presenterProvider
        self.dependenciesEngine = dependenciesEngine
        self.drawer = drawer
    }
    
    func gotoPartialAmortization(for loan: LoanEntity) {
        legacyExternalDependenciesResolver
            .loanRepaymentCoordinator()
            .set(loan.representable)
            .start()
    }
}
