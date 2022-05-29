import Foundation

public struct OrderDetailDTO: Codable {
    // basic data
    public var updatedOrderDate: Date?
    
    // detail
    public var stockName: String?
    public var orderedShares: Int?
    public var pendingShares: Int?
    public var exchange: AmountDTO?
    public var limitDate: Date?
    public var signatureDTO: SignatureDTO?
    public var holder: String?

    public init () {}
}
