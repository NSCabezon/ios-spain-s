import SANLegacyLibrary
import Foundation
import CoreFoundationLib

enum TransferEmittedType {
    case sepa
    case noSepa
}

class TransferEmitted {
    
    static func create(_ from: TransferEmittedDTO) -> TransferEmitted {
        return TransferEmitted(dto: from)
    }
    
    static func create(_ entity: TransferEmittedEntity) -> TransferEmitted {
        return TransferEmitted(dto: entity.dto)
    }
    
    private(set) var transferDTO: TransferEmittedDTO
    
    init(dto: TransferEmittedDTO) {
        transferDTO = dto
    }
    
    var entity: TransferEmittedEntity {
        return TransferEmittedEntity(transferDTO)
    }
    
    var executedDate: Date? {
        return transferDTO.executedDate
    }
    
    var beneficiary: String? {
        return transferDTO.beneficiary
    }
    
    var concept: String? {
        return transferDTO.concept
    }
    
    var amount: Amount? {
        return Amount.createFromDTO(transferDTO.amount)
    }
    
    var type: TransferEmittedType? {
        if transferDTO.amount?.currency?.currencyType == .eur && transferDTO.transferType != "NS" {
           return .sepa
        }
        return .noSepa
    }
}
