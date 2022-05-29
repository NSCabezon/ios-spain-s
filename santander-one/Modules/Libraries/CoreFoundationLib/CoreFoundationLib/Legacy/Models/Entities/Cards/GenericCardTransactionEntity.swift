import Foundation

public protocol CardTransactionEntityProtocol {
    var description: String? { get }
    var amount: AmountEntity? { get }
    var transactionDate: Date? { get }
    var type: CardTransactionType { get }
    var valueDate: String? { get }
}

public enum CardTransactionType {
    case pendingTransaction
    case transaction
}
