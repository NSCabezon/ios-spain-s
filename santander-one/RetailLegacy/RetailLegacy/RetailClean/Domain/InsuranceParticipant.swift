import SANLegacyLibrary

class InsuranceParticipant: GenericProduct {
    
    var name: String? {
        return dto.name
    }
    
    var surname1: String? {
        return dto.surname1
    }
    
    var surname2: String? {
        return dto.surname2
    }
    
    static func create(_ from: InsuranceParticipantDTO) -> InsuranceParticipant {
        return InsuranceParticipant(from)
    }
    
    private(set) var dto: InsuranceParticipantDTO
    
    init(_ dto: InsuranceParticipantDTO) {
        self.dto = dto
        super.init()
    }
}
