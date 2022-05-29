import CoreFoundationLib
import Foundation
import SANLegacyLibrary

struct CardTransaction: CardTransactionProtocol, CardTransactionPkProtocol {
    let dto: CardTransactionDTO
    
    init(entity: CardTransactionEntity) {
        self.dto = entity.dto
    }
    
    init(_ dto: CardTransactionDTO) {
        self.dto = dto
    }
    
    var transactionDate: Date? {
        return dto.operationDate
    }
    
    var operationDate: Date? {
        return dto.operationDate
    }
    var description: String? {
        return dto.description
    }
    var amount: Amount {
        return Amount.createFromDTO(dto.amount)
    }
    var annotationDate: Date? {
        return dto.annotationDate
    }
    var transactionDay: String? {
        return dto.transactionDay
    }
}
