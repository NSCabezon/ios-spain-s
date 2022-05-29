import SANLegacyLibrary

public final class WithholdingEntity: DTOInstantiable {
    
    public let dto: WithholdingDTO
    
    public init(_ dto: WithholdingDTO) {
        self.dto = dto
    }
    
    public var entryDate: Date {
        return dto.entryDate
    }
    
    public var leavingDate: Date {
        return dto.leavingDate
    }
    public var concept: String {
        return dto.concept
    }
    public var amount: Decimal {
        return dto.amount
    }
}
