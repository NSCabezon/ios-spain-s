import CoreDomain
public struct ManagerDTO: Codable {
    public var codGest: String?
    public var nameGest: String?
    public var category: String?
    public var portfolio: String?
    public var desTipCater: String?
    public var phone: String?
    public var email: String?
    public var indPriority: Int?
    public var portfolioType: String?
    public var thumbnailData: Data? = nil
    public init () {}
}

extension ManagerDTO: PersonalManagerRepresentable {}
