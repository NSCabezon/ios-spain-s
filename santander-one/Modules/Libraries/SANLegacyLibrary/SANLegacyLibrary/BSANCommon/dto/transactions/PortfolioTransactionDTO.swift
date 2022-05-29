import Foundation

public struct PortfolioTransactionDTO: BaseTransactionDTO {
    public var logTag: String {
        return String(describing: type(of: self))
    }
    public var operationDate: Date?
    public var amount: AmountDTO?
    public var description: String?
    
    public var sharesCount: Decimal?
    public var transactionNumber: String?
    public var transactionType: String?
    public var valueDate: Date?

    public init() {}
}
