public protocol OldLoanDetailModifierProtocol {
    var isEnabledFirstHolder: Bool { get }
    var isEnabledInitialExpiration: Bool { get }
    var aliasIsNeeded: Bool { get }
    var isEnabledLastOperationDate: Bool { get }
    var isEnabledNextInstallmentDate: Bool { get }
    var isEnabledCurrentInterestAmount: Bool { get }
    func formatLoanId(_ loanId: String) -> String
    func formatPeriodicity(_ periodicity: String) -> String?
}

public extension OldLoanDetailModifierProtocol {
    var isEnabledLastOperationDate: Bool { false }
}
