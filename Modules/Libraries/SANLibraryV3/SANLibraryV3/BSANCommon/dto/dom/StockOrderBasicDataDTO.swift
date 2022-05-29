import Foundation

public struct StockOrderBasicDataDTO: Codable {
    public var orderDate: Date?
    public var ticker: String?
    public var operationDescription: String?
    public var situation: String?
}
