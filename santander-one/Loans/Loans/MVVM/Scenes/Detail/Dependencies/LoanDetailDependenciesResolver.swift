import CoreFoundationLib
import CoreDomain
import Foundation
import Localization

protocol LoanDetailDependenciesResolver {
    var external: LoanDetailExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> LoanDetailViewModel
    func resolve() -> LoanDetailViewController
    func resolve() -> LoanDetailCoordinator
    func resolve() -> GetLoanDetailConfigUseCase
}

extension LoanDetailDependenciesResolver {
    func resolve() -> LoanDetailViewModel {
        return LoanDetailViewModel(dependencies: self)
    }
    
    func resolve() -> LoanDetailViewController {
        return LoanDetailViewController(dependencies: self)
    }
    
    func resolve() -> GetLoanDetailConfigUseCase {
        return DefaultGetLoanDetailConfigUseCase(dependencies: self)
    }
}
