import SANLegacyLibrary
import Foundation

public class NoSepaPayeeEntity: DTOInstantiable {

    public let dto: NoSepaPayeeDTO
    
    public required init(_ dto: NoSepaPayeeDTO) {
        self.dto = dto
    }
    
    public var countryName: String? {
        return self.dto.countryName
    }
    
    public var countryCode: String? {
        return self.dto.countryCode
    }
    
    public var bankCountryCode: String? {
        return self.dto.bankCountryCode
    }
    
    public var address: String? {
        return self.dto.address
    }
    
    public var town: String? {
        return self.dto.town
    }
    
    public var swiftCode: String? {
        return self.dto.swiftCode
    }
}
