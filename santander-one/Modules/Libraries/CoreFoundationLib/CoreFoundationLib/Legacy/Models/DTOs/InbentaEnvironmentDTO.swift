public class InbentaEnvironmentDTO: Codable, Hashable, CustomStringConvertible, Equatable {
    let name: String?
    let urlBase: String?
    let token: String
    
    public init(_ name: String?, _ urlBase: String?, _ token: String) {
        self.name = name
        self.urlBase = urlBase
        self.token = token
    }
    
    public var description: String {
        return "\(name ?? ""): \(urlBase ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        let result = 32 * (name?.hashValue ?? 0) + (urlBase?.hashValue ?? 0)
        hasher.combine(result)
    }
    
    public static func == (lhs: InbentaEnvironmentDTO, rhs: InbentaEnvironmentDTO) -> Bool {
        return rhs.name == lhs.name && rhs.urlBase == lhs.urlBase
    }
}
