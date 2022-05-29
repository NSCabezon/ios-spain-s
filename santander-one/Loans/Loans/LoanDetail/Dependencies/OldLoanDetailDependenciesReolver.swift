import CoreFoundationLib

protocol OldLoanDetailDependenciesResolver {
    var external: LoanDetailExternalDependenciesResolver { get }
    func resolve() -> DataBinding
}
