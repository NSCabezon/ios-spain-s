import Foundation

public struct StockDataBuySellDTO: Codable {
    public var linkedAccountBalance: AmountDTO?
    public var limitDate: Date?
    public var holder: String?
    public var nameStock: String?
    public var linkedAccountDescription: String?
    public var descContract: String?
    public var signature: SignatureDTO?

    public init () {}
}
