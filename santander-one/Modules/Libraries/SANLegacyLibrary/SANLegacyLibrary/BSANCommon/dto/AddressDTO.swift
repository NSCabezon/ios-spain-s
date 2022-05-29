import CoreDomain

public struct AddressDTO: Codable {
    public let address: String?
    public let locality: String?
    public let country: String
    
    public init(country: String, address: String? = nil, locality: String? = nil) {
        self.address = address
        self.locality = locality
        self.country = country
    }
}
