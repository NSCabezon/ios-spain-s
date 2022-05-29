import Foundation

public struct StockOperationDataConfirmDTO: Codable {
    public var negotiationDate: Date?
    public var negotiationTime: Date?
    public var stockOrderNumber: String?

    public init () {}
}
