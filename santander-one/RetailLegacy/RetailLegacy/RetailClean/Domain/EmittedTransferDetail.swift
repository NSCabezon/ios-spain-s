import SANLegacyLibrary
import Foundation

class EmittedTransferDetail {
    
    static func create(_ from: TransferEmittedDetailDTO) -> EmittedTransferDetail {
        return EmittedTransferDetail(dto: from)
    }

    private(set) var transferDetailDTO: TransferEmittedDetailDTO
    init(dto: TransferEmittedDetailDTO) {
        transferDetailDTO = dto
    }

    var origin: IBAN? {
        guard let iban = transferDetailDTO.origin else { return nil }
        return IBAN(dto: iban)
    }

    var beneficiary: IBAN? {
        guard let iban = transferDetailDTO.beneficiary else { return nil }
        return IBAN(dto: iban)
    }

    var transferAmount: Amount? {
        return Amount.createFromDTO(transferDetailDTO.transferAmount)
    }
    
    var beneficiaryName: String? {
        return transferDetailDTO.beneficiaryName
    }
    
    var emisionDate: Date? {
        return transferDetailDTO.emisionDate
    }
    
    var valueDate: Date? {
        return transferDetailDTO.valueDate
    }
    
    var fees: Amount? {
        return Amount.createFromDTO(transferDetailDTO.banckCharge)
    }
    
    var totalAmount: Amount? {
        return Amount.createFromDTO(transferDetailDTO.netAmount)
    }
}
