import Foundation

public struct AviosDetailDTO: Codable {
    public var totalPoints: Int?
    public var iberiaPlusCode: String?
    public var lastLiquidationTotalPoints: Int?
    
    public init(totalPoints: Int?, iberiaPlusCode: String?, lastLiquidationTotalPoints: Int?) {
        self.totalPoints = totalPoints
        self.iberiaPlusCode = iberiaPlusCode
        self.lastLiquidationTotalPoints = lastLiquidationTotalPoints
    }
    
    private enum CodingKeys: String, CodingKey {
        case totalPoints = "totalAvios"
        case iberiaPlusCode = "codigoIberiaPlus"
        case lastLiquidationTotalPoints = "totalAviosUltimaLiquidacion"
    }
}
