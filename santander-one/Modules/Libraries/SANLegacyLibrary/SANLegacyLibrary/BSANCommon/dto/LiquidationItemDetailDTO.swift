import Foundation

public struct LiquidationItemDetailDTO: Codable {
    public var validityOpeningDate: Date?
    public var validityClosingDate: Date?
    public var settlementAmount: AmountDTO?
    public var liquidationFee: Decimal?
    public var liquidationFeeFormatted: String?
    public var liquidationDescription: String?
    
    public init() {}
}
