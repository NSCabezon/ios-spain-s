public struct BranchLocatorATMParameters: Codable {
    public var lat: Double
    public var lon: Double
    public var customer: Bool = false
    public var country: String = "ES"
    public var config: String?
    
    public init(lat: Double, lon: Double, customer: Bool, country: Country) {
        self.customer = customer
        self.country = country.rawValue.uppercased()
        self.lat = lat
        self.lon = lon
    }
}
