import Foundation
import CoreDomain

public struct LoanTransactionDTO: BaseTransactionDTO {
    public var operationDate: Date?
    public var amount: AmountDTO?
    public var description: String?
    public var bankOperation: BankOperationDTO?
    public var balance: AmountDTO?
    public var dgoNumber: DGONumberDTO?
    public var titular: String?
    public var valueDate: Date?
    public var transactionNumber: String?
    public var receiptId: String?
    
    public init() {}
}

extension  LoanTransactionDTO: LoanTransactionRepresentable {
    public var amountRepresentable: AmountRepresentable? {
        return amount
    }
    
    public var bankOperationRepresentable: BankOperationRepresentable? {
        return bankOperation
    }
    
    public var balanceRepresentable: AmountRepresentable? {
        return balance
    }
    
    public var dgoNumberRepresentable: DGONumberRepresentable? {
        return dgoNumber
    }
}
