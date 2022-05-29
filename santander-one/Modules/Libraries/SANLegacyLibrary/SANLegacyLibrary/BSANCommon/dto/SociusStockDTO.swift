import Foundation

public struct SociusStockDTO: Codable {
    public var endDate: Date?
    public var startDate: Date?
    public var totalAccumulated: AmountDTO?
    public var amountLastLiquidation: AmountDTO?
    public var description: String?
    public var code: String?

    public init () {}
}
