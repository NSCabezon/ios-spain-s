import Foundation

public struct FinancialGroupDTO: Codable {
    public let identifier, title: String
    public let aggregations: [FinancialAggregationDTO]
    public let links: [LinkDTO]?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title
        case aggregations
        case links
    }
}
