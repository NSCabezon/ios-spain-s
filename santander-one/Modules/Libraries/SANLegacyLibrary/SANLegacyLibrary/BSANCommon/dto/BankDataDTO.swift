import CoreDomain
public struct BankDataDTO: Codable {
    public let name: String
    public let address: String?
    public let location: String?
    public let country: String?
    
    public init(name: String, address: String?, location: String?, country: String?) {
        self.name = name
        self.address = address
        self.location = location
        self.country = country
    }
}
