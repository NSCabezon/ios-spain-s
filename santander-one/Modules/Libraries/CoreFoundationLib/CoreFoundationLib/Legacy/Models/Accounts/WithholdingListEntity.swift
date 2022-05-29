import SANLegacyLibrary

public final class WithholdingListEntity: DTOInstantiable {
    
    public let dto: WithholdingListDTO
    
    public init(_ dto: WithholdingListDTO) {
        self.dto = dto
    }
    
    public var transactions: [WithholdingEntity] {
        return dto.withholdingDTO.map(WithholdingEntity.init)
    }
}
