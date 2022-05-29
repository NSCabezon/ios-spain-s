import SANLegacyLibrary
import CoreFoundationLib

struct AccountDescriptor {
    
    static func create(_ from: AccountDescriptorDTO) -> AccountDescriptor {
        return AccountDescriptor(dto: from)
    }
    
    var accountDescriptorDTO: AccountDescriptorDTO
    
    var type: String {
        return accountDescriptorDTO.type!
    }
    
    var subType: String {
        return accountDescriptorDTO.subType!
    }
    
    private init(dto: AccountDescriptorDTO) {
        accountDescriptorDTO = dto
    }
}
