import SANLegacyLibrary
import Foundation
import CoreFoundationLib

class NoSepaPayeeDetail: BaseNoSepaPayeeDetailProtocol {
    
    static func create(_ from: NoSepaPayeeDetailDTO) -> NoSepaPayeeDetail {
        return NoSepaPayeeDetail(dto: from)
    }
    
    convenience init(entity: NoSepaPayeeDetailEntity) {
        self.init(dto: entity.dto)
    }
         
    private(set) var noSepaPayeeDetailDTO: NoSepaPayeeDetailDTO
    
    internal init(dto: NoSepaPayeeDetailDTO) {
        noSepaPayeeDetailDTO = dto
    }
    
    var bicSwift: String? {
        return self.payee?.swiftCode
    }
    
    var transferAmount: Amount {
        return Amount.createFromDTO(noSepaPayeeDetailDTO.amount)
    }
    
    var destinationCountryCode: String? {
        return bankCountryCode?.isEmpty == false ? bankCountryCode : countryCode
    }
    
    var countryCode: String? {
        return self.payee?.countryCode
    }
    
    var countryName: String? {
        return self.payee?.countryName
    }
    
    var payee: NoSepaPayee? {
        guard let payeeDTO = noSepaPayeeDetailDTO.payee else { return nil }
        return NoSepaPayee(dto: payeeDTO)
    }
    
    var concept1: String? {
        return noSepaPayeeDetailDTO.concept
    }
    
    var alias: String? {
        return noSepaPayeeDetailDTO.alias
    }
    
    var codePayee: String? {
        return noSepaPayeeDetailDTO.codPayee
    }
    
    var accountType: NoSepaAccountType? {
        return noSepaPayeeDetailDTO.accountType
    }
    
    var payeeAddress: String? {
        return payee?.address
    }
    
    var payeeLocation: String? {
        return payee?.town
    }
    
    var payeeCountry: String? {
        return payee?.countryName
    }
    
    var bankName: String? {
        return payee?.bankName
    }
    
    var bankAddress: String? {
        return payee?.bankAddress
    }
    
    var bankLocation: String? {
        return payee?.bankTown
    }
    
    var bankCountry: String? {
        return payee?.bankCountryName
    }
    
    var bankCountryCode: String? {
        return payee?.bankCountryCode
    }
    
}
