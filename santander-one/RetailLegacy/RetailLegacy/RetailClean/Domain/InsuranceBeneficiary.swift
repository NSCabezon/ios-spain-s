import SANLegacyLibrary

class InsuranceBeneficiary: GenericProduct {
    
    var name: String? {
        return dto.name
    }
    
    var type: String? {
        return dto.type
    }
    
    static func create(_ from: InsuranceBeneficiaryDTO) -> InsuranceBeneficiary {
        return InsuranceBeneficiary(from)
    }
    
    private(set) var dto: InsuranceBeneficiaryDTO
    
    init(_ dto: InsuranceBeneficiaryDTO) {
        self.dto = dto
        super.init()
    }
}
