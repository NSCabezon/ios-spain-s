import Foundation

public struct LiquidationDTO: Codable {
    public var validityOpeningDate: Date?
    public var validityClosingDate: Date?
    public var settlementAmount: AmountDTO?

    public init() {}
}
