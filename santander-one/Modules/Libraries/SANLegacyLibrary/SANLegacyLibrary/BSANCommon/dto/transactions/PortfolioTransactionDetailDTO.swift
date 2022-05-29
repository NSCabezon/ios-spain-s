import Foundation

public struct PortfolioTransactionDetailDTO: Codable {
    public var valueDate: Date?
    public var expensesAmount: AmountDTO?
    public var linkedAccountDesc: String?
    public var sharesCount: Decimal?
    public var transactionType: String?
    public var operationDate: Date?
    public var amount: AmountDTO?

    public init() {}
}
