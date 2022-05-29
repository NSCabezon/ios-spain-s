import SANLegacyLibrary

public struct AviosDetail: DTOInstantiable {
    public var dto: AviosDetailDTO
    
    public init(_ dto: AviosDetailDTO) {
        self.dto = dto
    }
    
    public var totalPoints: Int? {
        dto.totalPoints
    }
    
    public var iberiaPlusCode: String? {
        dto.iberiaPlusCode
    }
    
    public var lastLiquidationTotalPoints: Int? {
        dto.lastLiquidationTotalPoints
    }
}
