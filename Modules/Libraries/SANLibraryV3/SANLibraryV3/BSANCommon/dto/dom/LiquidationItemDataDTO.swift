import Foundation

public struct LiquidationItemDataDTO: Codable {
    public var validityOpeningDate: Date?
    public var validityClosingDate: Date?
    public var settlementAmount: AmountDTO?
}
