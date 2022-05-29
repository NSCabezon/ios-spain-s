import CoreDomain

public struct CategoryDTO: Codable {
    public let name: String?
    public let imageRelativeURL: String?
    public let iconRelativeURL: String?
    public let items: [ItemDTO]?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case imageRelativeURL
        case iconRelativeURL = "iconRelativeURLV2"
        case items
    }
}

extension CategoryDTO: CategoryRepresentable {
    public var itemsRepresentable: [ItemRepresentable]? {
        return items
    }
}
