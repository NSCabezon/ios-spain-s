import SANLegacyLibrary
import Foundation

class NoSepaPayee {
    static func create(_ from: NoSepaPayeeDTO) -> NoSepaPayee {
        return NoSepaPayee(dto: from)
    }
    
    private(set) var noSepaPayeeDTO: NoSepaPayeeDTO
    init(dto: NoSepaPayeeDTO) {
        noSepaPayeeDTO = dto
    }
    
    var swiftCode: String {
        return noSepaPayeeDTO.swiftCode ?? ""
    }
    
    var bicSwift: String? {
        guard
            let company = noSepaPayeeDTO.messageSwiftCenter?.company,
            let center = noSepaPayeeDTO.messageSwiftCenter?.center, !company.isEmpty, !center.isEmpty else {
                return nil
        }
        
        return company + center + swiftCode
    }
    
    var messageSwiftCenter: MessageSwiftCenterNoSepaPayee? {
        guard let messageSwiftCenterDTO = noSepaPayeeDTO.messageSwiftCenter else { return nil }
        return MessageSwiftCenterNoSepaPayee(dto: messageSwiftCenterDTO)
    }
    
    var paymentAccountDescription: String? {
        return noSepaPayeeDTO.paymentAccountDescription
    }
    
    var name: String? {
        return noSepaPayeeDTO.name
    }
    
    var town: String? {
        return noSepaPayeeDTO.town
    }
    
    var address: String? {
        return noSepaPayeeDTO.address
    }
    
    var countryName: String? {
        return noSepaPayeeDTO.countryName
    }
    
    var countryCode: String? {
        return noSepaPayeeDTO.countryCode
    }
    
    var residentIndicator: String? {
        return noSepaPayeeDTO.residentIndicator
    }
    
    var bankName: String? {
        return noSepaPayeeDTO.bankName
    }
    
    var bankAddress: String? {
        return noSepaPayeeDTO.bankAddress
    }
    
    var bankTown: String? {
        return noSepaPayeeDTO.bankTown
    }
    
    var bankCountryName: String? {
        return noSepaPayeeDTO.bankCountryName
    }
    
    var bankCountryCode: String? {
        return noSepaPayeeDTO.bankCountryCode
    }
    
    var residentDescription: String? {
        return noSepaPayeeDTO.residentDescription
    }
}
