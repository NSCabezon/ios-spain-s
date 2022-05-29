import Foundation

public struct ImpositionTransactionDTO: BaseTransactionDTO{
    public var operationDate: Date?
    public var amount: AmountDTO?
    public var description: String?
    
    public var valueDate: Date?
    public var transactionNumber: String?
    
    public init() {}
}
