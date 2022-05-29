public struct BizumContactList {
    public var surname: String?
    public var phone: String
    public var thumbnailData: Data?
    public var identifier: String
    public let name: String?
    public let isBizum: Bool

    public init(name: String? = nil,
                phone: String,
                isBizum: Bool = false,
                thumbnailData: Data?) {
        self.identifier = name ?? phone
        self.name = name
        self.phone = phone
        self.isBizum = isBizum
        self.thumbnailData = thumbnailData
    }
}

extension BizumContactList: Hashable {
    public static func == (lhs: BizumContactList, rhs: BizumContactList) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
