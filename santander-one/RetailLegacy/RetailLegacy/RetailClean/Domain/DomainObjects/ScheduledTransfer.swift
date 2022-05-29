import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

struct ScheduledTransfer {
    
    private(set) var dto: ValidateScheduledTransferDTO
    
    var dataMagicPhrase: String? {
        return dto.dataMagicPhrase
    }
    
    var bankChargeAmount: Amount? {
        guard let commission = dto.commission else { return nil }
        return Amount.createFromDTO(commission)
    }
    
    var nameBeneficiaryBank: String? {
        return dto.nameBeneficiaryBank
    }
    
    var code: String? {
        return dto.actuanteCode
    }
    
    var number: String? {
        return dto.actuanteNumber
    }
    
    var company: String? {
        return dto.actuanteCompany
    }
    
    var scaRepresentable: SCARepresentable? {
        return dto.scaRepresentable
    }
}
