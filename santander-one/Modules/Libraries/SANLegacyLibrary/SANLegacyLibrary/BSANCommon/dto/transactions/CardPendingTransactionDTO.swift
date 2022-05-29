import Foundation

public struct CardPendingTransactionDTO: Codable {
    public var cardNumber: String?
    public var annotationDate: Date?
    public var transactionTime: String?
    public var amount: AmountDTO?
    public var description: String?

    public init() {}
}
