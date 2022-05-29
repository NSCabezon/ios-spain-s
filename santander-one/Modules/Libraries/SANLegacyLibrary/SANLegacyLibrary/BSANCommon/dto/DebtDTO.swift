import Foundation

public struct DebtDTO: Codable {
    public var operationDate: Date?
    public var totalDebt: AmountDTO?

    public init() {}
}
