import CoreDomain

public struct DGONumberDTO: Codable {
    public var number: String?
    public var terminalCode: String?
    public var center: String?
    public var company: String?
    public var description: String? {
        return "\(self.company ?? "")-\(self.center ?? "")-\(self.terminalCode ?? "")-\(self.number ?? "")"
    }
    
    public init() {}
    
    public init(string: String) {
        let split = string.components(separatedBy: "-")
        self.company = split.count > 0 ? split[0]: nil
        self.center = split.count > 1 ? split[1]: nil
        self.terminalCode = split.count > 2 ? split[2]: nil
        self.number = split.count > 3 ? split[3]: nil
    }
}

extension DGONumberDTO: DGONumberRepresentable {}
