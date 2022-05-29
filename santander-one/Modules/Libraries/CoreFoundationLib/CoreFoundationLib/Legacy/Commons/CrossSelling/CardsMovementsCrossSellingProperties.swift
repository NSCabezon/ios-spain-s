import Foundation

public struct CardsMovementsCrossSellingProperties: CrossSellingRepresentable, Hashable {
    public let tagsCrossSelling: [String]
    public let amountCrossSelling: Decimal?
    public let actionNameCrossSelling: String
    public let cardTypeCrossSelling: [String: String]?
    public let crossSellingType: CrossSellingType = .cards
    
    public init(entity: CardsMovementsCrossSellingEntity) {
        self.tagsCrossSelling = entity.tagsCardMovementsCrossSelling ?? []
        self.amountCrossSelling = entity.amountCardMovementsCrossSelling?.stringToDecimal
        self.actionNameCrossSelling = entity.actionCardMovementsCrossSelling ?? ""
        self.cardTypeCrossSelling = entity.typeCard
    }
}

public struct CardsMovementsCrossSellingEntity: Codable {
    public let tagsCardMovementsCrossSelling: [String]?
    public let amountCardMovementsCrossSelling: String?
    public let actionCardMovementsCrossSelling: String?
    public let typeCard: [String: String]?
}
