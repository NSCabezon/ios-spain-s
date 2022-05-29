import Foundation

public struct SociusReceiptDTO: Codable {
    public var sociusReceiptDetailDTOList: [SociusReceiptDetailDTO] = []
    public var endDate: Date?
    public var startDate: Date?
    public var totalAccumulated: AmountDTO?
    public var lastLiquidationAmount: AmountDTO?
    public var description: String?
    public var code: String?

    public init () {}
}
