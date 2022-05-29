import Foundation

public struct SociusLiquidationDTO: Codable {
    public var receipts: [SociusReceiptDTO] = []
    public var stocks: [SociusStockDTO] = []
    public var startDate: Date?
    public var endDate: Date?
    public var interestsLastLiquidation: AmountDTO?
    public var interestsTotalAccumulated: AmountDTO?
    public var accountPaidLastLiquidation: AmountDTO?
    public var accountPaidTotalAccumulated: AmountDTO?
    public var cashbackLastLiquidation: AmountDTO?
    public var cashbackTotalAccumulated: AmountDTO?
    public var stocksLastLiquidation: AmountDTO?
    public var stocksTotalAccumulated: AmountDTO?

    public init () {}
}
