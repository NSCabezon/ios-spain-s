import Foundation

public struct FinancialAggregationDTO: Codable {
    public let field: String
    public let title: String
    public let value: ValueDTO
}
