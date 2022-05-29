public struct BizumFrequentViewModel {
    public let identifier: String?
    public let name: String?
    public let phone: String
    public let avatarName: String
    public let avatarColor: UIColor
    
    public init(identifier: String?, name: String?, phone: String, avatarName: String, avatarColor: UIColor) {
        self.identifier = identifier
        self.name = name
        self.phone = phone
        self.avatarName = avatarName
        self.avatarColor = avatarColor
    }
}

extension BizumFrequentViewModel: Hashable {
    static public func == (lhs: BizumFrequentViewModel, rhs: BizumFrequentViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public var hashValue: Int {
        if let identifier = identifier, let hash = Int(identifier) {
            return hash
        }
        return 0
    }
}
