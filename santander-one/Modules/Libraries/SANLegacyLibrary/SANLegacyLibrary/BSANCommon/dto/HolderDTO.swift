import CoreDomain

public struct HolderDTO: Codable {
    public var name: String?
    public var ownershipTypeDesc: OwnershipTypeDesc?

    public init() {}
}
