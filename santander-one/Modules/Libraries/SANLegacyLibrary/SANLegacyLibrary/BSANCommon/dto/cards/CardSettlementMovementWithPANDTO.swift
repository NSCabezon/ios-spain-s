import Foundation

public struct CardSettlementMovementWithPANDTO: Codable {
    public var pan: String?
    public var transactions: [CardSettlementMovementDTO]?
}
