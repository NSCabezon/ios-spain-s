import Foundation
import CoreDomain

struct MockLoanTransaction: LoanTransactionRepresentable {
    var operationDate: Date?
    var amountRepresentable: AmountRepresentable?
    var description: String?
    var bankOperationRepresentable: BankOperationRepresentable?
    var balanceRepresentable: AmountRepresentable?
    var dgoNumberRepresentable: DGONumberRepresentable?
    var titular: String?
    var valueDate: Date?
    var transactionNumber: String?
    var receiptId: String?
}
