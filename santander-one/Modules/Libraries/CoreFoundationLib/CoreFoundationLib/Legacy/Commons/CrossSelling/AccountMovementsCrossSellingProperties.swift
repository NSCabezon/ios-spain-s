import Foundation

public struct AccountMovementsCrossSellingProperties: Hashable, CrossSellingRepresentable {
    public let tagsCrossSelling: [String]
    public let amountCrossSelling: Decimal?
    public let actionNameCrossSelling: String
    public let accountAmountCrossSelling: Decimal?
    public let crossSellingType: CrossSellingType = .accounts

    public init(entity: AccountMovementsCrossSellingEntity) {
        self.tagsCrossSelling = entity.tagsAccountMovementsCrossSelling ?? []
        self.amountCrossSelling = entity.amountAccountMovementsCrossSelling?.stringToDecimal
        self.actionNameCrossSelling = entity.actionAccountMovementsCrossSelling ?? ""
        self.accountAmountCrossSelling = entity.amountAccount?.stringToDecimal
    }
}

public struct AccountMovementsCrossSellingEntity: Codable {
    public let tagsAccountMovementsCrossSelling: [String]?
    public let amountAccountMovementsCrossSelling: String?
    public let actionAccountMovementsCrossSelling: String?
    public let amountAccount: String?
}
