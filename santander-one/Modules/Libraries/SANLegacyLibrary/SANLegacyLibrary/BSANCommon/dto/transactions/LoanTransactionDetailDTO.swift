import CoreDomain

public struct LoanTransactionDetailDTO: Codable {
    public var feeAmount: AmountDTO?
    public var capital: AmountDTO?
    public var interestAmount: AmountDTO?
    public var pendingAmount: AmountDTO?
    public var recipientAccountNumber: String?
    public var recipientData: String?

    public init() {}
}

extension LoanTransactionDetailDTO: LoanTransactionDetailRepresentable {
    public var capitalRepresentable: AmountRepresentable? {
        return capital
    }
    
    public var interestRepresentable: AmountRepresentable? {
        return interestAmount
    }
    
    public var feeRepresentable: AmountRepresentable? {
        return feeAmount
    }
    
    public var pendingAmountRepresentable: AmountRepresentable? {
        return pendingAmount
    }
}
