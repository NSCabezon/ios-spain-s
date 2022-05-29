import Foundation

public protocol LoanTransactionDetailRepresentable {
    var capitalRepresentable: AmountRepresentable? { get }
    var interestRepresentable: AmountRepresentable? { get }
    var recipientAccountNumber: String? { get }
    var recipientData: String? { get }
    var feeRepresentable: AmountRepresentable? { get }
    var pendingAmountRepresentable: AmountRepresentable? { get }
}
