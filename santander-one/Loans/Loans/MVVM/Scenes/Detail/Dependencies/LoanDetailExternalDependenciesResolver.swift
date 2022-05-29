import UI
import CoreFoundationLib
import Foundation
import CoreDomain

public protocol LoanDetailExternalDependenciesResolver: ShareDependenciesResolver, NavigationBarExternalDependenciesResolver, LoanCommonExternalDependenciesResolver {    
    
    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func resolve() -> NavigationBarItemBuilder
    func loanDetailCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> Coordinator
    func resolve() -> AppConfigRepositoryProtocol
    func globalSearchCoordinator() -> Coordinator
    func resolve() -> LoanDetailConfigRepresentable
    func resolve() -> StringLoader
    func resolve() -> TrackerManager
}

extension LoanDetailExternalDependenciesResolver {
    
    public func loanDetailCoordinator() -> BindableCoordinator {
        return DefaultLoanDetailCoordinator(dependencies: self, navigationController: resolve())
    }
    
    public func resolve() -> LoanDetailConfigRepresentable {
        return DefaultLoanDetailConfig()
    }
}
