import Foundation

public struct FinancialAgregatorDTO: Codable {
    public let identifier, title: String
    public let aggregations: [FinancialAggregationDTO]
    public let productGroups: [FinancialProductGroupDTO]
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title
        case aggregations
        case productGroups
    }
}

// MARK: - Value
public struct ValueDTO: Codable {
    public let amount: Double
    public let currency: String
}

// MARK: - Link
public struct LinkDTO: Codable {
    public let rel: String
    public let ref: String?
}

