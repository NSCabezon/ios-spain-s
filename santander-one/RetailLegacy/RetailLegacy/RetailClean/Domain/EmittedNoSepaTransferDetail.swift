import SANLegacyLibrary
import Foundation

public enum EmittedNoSepaTransferIndicatorExpenses: String {
    case shared = "SHA"
    case beneficiary = "BEN"
    case payer = "OUR"
}

class EmittedNoSepaTransferDetail: BaseNoSepaPayeeDetailProtocol {
    private(set) var noSepaTransferDetailDTO: NoSepaTransferEmittedDetailDTO
    
    init(dto: NoSepaTransferEmittedDetailDTO) {
        self.noSepaTransferDetailDTO = dto
    }
    
    var bicSwift: String? {
        return self.payee?.bicSwift
    }
    
    var originAccount: IBAN? {
        guard let iban = noSepaTransferDetailDTO.origin else { return nil }
        return IBAN(dto: iban)
    }
    
    var transferAmount: Amount {
        return Amount.createFromDTO(noSepaTransferDetailDTO.transferAmount)
    }
    
    var emisionDate: Date? {
        return noSepaTransferDetailDTO.emisionDate
    }
    
    var valueDate: Date? {
        return noSepaTransferDetailDTO.valueDate
    }
    
    var originName: String? {
        return noSepaTransferDetailDTO.originName
    }
    
    var spentIndicator: String? {
        return noSepaTransferDetailDTO.spentIndicator
    }
    
    var transferType: String? {
        return noSepaTransferDetailDTO.transferType
    }
    
    var destinationCountryCode: String? {
        return countryCode
    }
    
    var countryCode: String? {
        return noSepaTransferDetailDTO.countryCode
    }
    
    var countryName: String? {
        return noSepaTransferDetailDTO.countryName
    }
    
    var concept1: String? {
        return noSepaTransferDetailDTO.concept1
    }
    
    var spentDescIndicator: String? {
        return noSepaTransferDetailDTO.spentDescIndicator
    }
    
    var descTransferType: String? {
        return noSepaTransferDetailDTO.descTransferType
    }
    
    var payee: NoSepaPayee? {
        guard let payeeDTO = noSepaTransferDetailDTO.payee else { return nil }
        return NoSepaPayee(dto: payeeDTO)
    }
    
    var entityAuthPayment: EntityAuthPayment? {
        guard let entityAuthPaymentDTO = noSepaTransferDetailDTO.entityAuthPayment else { return nil }
        return EntityAuthPayment(dto: entityAuthPaymentDTO)
    }
    
    var expensesIndicator: EmittedNoSepaTransferIndicatorExpenses? {
        return EmittedNoSepaTransferIndicatorExpenses(rawValue: noSepaTransferDetailDTO.expensesIndicator ?? "")
    }
}
