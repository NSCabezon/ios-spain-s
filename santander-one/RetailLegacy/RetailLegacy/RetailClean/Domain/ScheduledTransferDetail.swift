import SANLegacyLibrary
import Foundation
import CoreFoundationLib

class ScheduledTransferDetail {
    
    static func create(_ from: TransferScheduledDetailDTO) -> ScheduledTransferDetail {
        return ScheduledTransferDetail(dto: from)
    }

    private(set) var transferDetailDTO: TransferScheduledDetailDTO

    init(dto: TransferScheduledDetailDTO) {
        transferDetailDTO = dto
    }
    
    lazy var entity: ScheduledTransferDetailEntity = {
        ScheduledTransferDetailEntity(dto: transferDetailDTO)
    }()
    
    var iban: IBAN? {
        guard let iban = transferDetailDTO.iban else { return nil }
        return IBAN(dto: iban)
    }

    var beneficiary: IBAN? {
        guard let iban = transferDetailDTO.ibanBeneficiary else { return nil }
        return IBAN(dto: iban)
    }

    var transferAmount: Amount? {
        return Amount.createFromDTO(transferDetailDTO.transferAmount)
    }
    
    var concept: String? {
        return transferDetailDTO.concept
    }

    var beneficiaryName: String? {
        return transferDetailDTO.beneficiary
    }

    var nextExecutionDate: Date? {
        return transferDetailDTO.dateNextExecution
    }

    var endDate: Date? {
        return transferDetailDTO.dateEndValidity
    }

    var dateValidFrom: Date? {
        return transferDetailDTO.dateStartValidity
    }
    
}
