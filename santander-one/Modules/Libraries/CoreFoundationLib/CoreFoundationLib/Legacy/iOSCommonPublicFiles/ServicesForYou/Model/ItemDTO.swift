import CoreDomain

public struct ItemDTO: Codable {
    public let name: String?
    public let link: String?
}

extension ItemDTO: ItemRepresentable { }
