import Foundation

public struct OrderDTO: Codable {
    // basic data
    public var orderDate: Date?
    public var ticker: String?
    public var operationDescription: String?
    public var situation: String?
    public var number: String?

    public init () {}
}
