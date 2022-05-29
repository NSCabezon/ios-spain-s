public struct PullOffersConfigCategoryDTO: Codable {
    public let identifier: String?
    public let name: String?
    public let iconRelativeURL: String?
    public let offers: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case iconRelativeURL
        case offers
    }
}
