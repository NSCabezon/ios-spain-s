import Foundation
import SANLegacyLibrary
import CoreDomain

public struct CardTransactionEntity: DTOInstantiable {
    public var representable: CardTransactionRepresentable
    // swiftlint:disable force_cast
    public var dto: CardTransactionDTO {
        get {
            precondition((representable as? CardTransactionDTO) != nil)
            return representable as! CardTransactionDTO
        }
        set(newValue) {
            precondition((representable as? CardTransactionDTO) != nil)
            representable = newValue
        }
    }
    public init(_ dto: CardTransactionDTO) {
        self.representable = dto
        self.dto = dto
    }
    
    public var identifier: String? {
        return dto.identifier
    }

    public var transactionDate: Date? {
        return dto.operationDate
    }

    public var operationDate: Date? {
        return dto.operationDate
    }
    
    public var description: String? {
        return dto.description
    }
    
    public var amount: AmountEntity? {
        guard let amount = dto.amount else { return nil }
        return AmountEntity(amount)
    }
    
    public var annotationDate: Date? {
        return dto.annotationDate
    }
    
    public var transactionDay: String? {
        return dto.transactionDay
    }
    
    public var balanceCode: String? {
        return dto.balanceCode
    }
}

extension CardTransactionEntity: CardTransactionEntityProtocol {
    public var valueDate: String? {
        return dto.postedDate
    }
    
    public var type: CardTransactionType {
        return .transaction
    }
}

extension CardTransactionEntity: CardTransactionPkProtocol {}

extension CardTransactionEntity: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dto.description)
        hasher.combine(dto.amount?.value)
        hasher.combine(dto.operationDate)
        hasher.combine(dto.annotationDate)
        hasher.combine(dto.transactionDay)
        hasher.combine(dto.balanceCode)
    }
}

public func == (lhs: CardTransactionEntity, rhs: CardTransactionEntity) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public class CardTransactionWithCardEntity {
    
    public var cardTransactionEntity: CardTransactionEntity
    public var cardEntity: CardEntity
    
    public init(cardTransactionEntity: CardTransactionEntity, cardEntity: CardEntity) {
        self.cardTransactionEntity = cardTransactionEntity
        self.cardEntity = cardEntity
    }
}
