import Foundation
import SANLegacyLibrary

struct CardPendingTransaction: CardTransactionProtocol {
    let dto: CardPendingTransactionDTO
    
    var transactionDate: Date? {
        return dto.annotationDate
    }
    var annotationDate: Date? {
        return dto.annotationDate
    }
    var transactionTime: String? {
        return dto.transactionTime
    }
    var description: String? {
        return dto.description
    }
    var cardNumber: String? {
        return dto.cardNumber
    }
    var amount: Amount {
        return Amount.createFromDTO(dto.amount)
    }
    
    init(_ dto: CardPendingTransactionDTO) {
        self.dto = dto
    }
}
