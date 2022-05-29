import Foundation

public struct RMVLineDetailDTO: Codable {
    public var priceAmount: AmountDTO?
    public var sharesCount: Decimal?
    public var columnDesc: String?
    public var valueAmount: AmountDTO?
    public var priceDate: String?

    public init() {}
}
