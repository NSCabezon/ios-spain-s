import Foundation

public struct FinancialProductGroupDTO: Codable {
    public let identifier, title: String
    public let aggregations: [FinancialAggregationDTO]
    public let groups: [FinancialGroupDTO]?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title
        case aggregations
        case groups = "productGroups"
    }
}
