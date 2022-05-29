import Foundation
import SANLegacyLibrary

public struct CardPendingTransactionEntity: DTOInstantiable {
    public let dto: CardPendingTransactionDTO
    
    public init(_ dto: CardPendingTransactionDTO) {
        self.dto = dto
    }

    public var transactionDate: Date? {
        return dto.annotationDate
    }
    
    public var annotationDate: Date? {
        return dto.annotationDate
    }
    
    public var transactionTime: String? {
        return dto.transactionTime
    }
    
    public var description: String? {
        return dto.description
    }
    
    public var cardNumber: String? {
        return dto.cardNumber
    }
    
    public var amount: AmountEntity? {
        guard let amount = dto.amount else { return nil }
        return AmountEntity(amount)
    }
}

extension CardPendingTransactionEntity: CardTransactionEntityProtocol {
    public var valueDate: String? {
        return " "
    }
    
    public var type: CardTransactionType {
        return .pendingTransaction
    }
}

extension CardPendingTransactionEntity: Equatable {
    public static func == (lhs: CardPendingTransactionEntity, rhs: CardPendingTransactionEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension CardPendingTransactionEntity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.transactionDate)
        hasher.combine(self.annotationDate)
        hasher.combine(self.transactionTime)
        hasher.combine(self.description)
        hasher.combine(self.cardNumber)
        hasher.combine(self.amount?.value)
    }
}
