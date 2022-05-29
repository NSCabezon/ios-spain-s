import SANLegacyLibrary

class InsuranceCoverage: GenericProduct {
    
    var name: String? {
        return dto.name
    }
    
    var insuredAmount: Amount? {
        return Amount.createFromDTO(dto.insuredAmount)
    }

    static func create(_ from: InsuranceCoverageDTO) -> InsuranceCoverage {
        return InsuranceCoverage(from)
    }
    
    private(set) var dto: InsuranceCoverageDTO
    
    init(_ dto: InsuranceCoverageDTO) {
        self.dto = dto
        super.init()
    }
}
