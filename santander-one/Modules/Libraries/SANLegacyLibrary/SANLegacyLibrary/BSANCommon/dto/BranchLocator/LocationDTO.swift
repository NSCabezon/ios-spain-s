//

public enum Country: String, Codable {
    case es = "ES"
}

public enum LocationType: String, Codable {
    case point = "Point"
}

public enum PoiStatus: String, Codable {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
    case unknown
}

public struct LocationDTO: Codable {
    public let type: LocationType
    public let coordinates: [Double]
    public let address, zipcode, city: String
    public let country: Country
    public let locationDetails, parking: String?
    public let geoCoords: GeoCoordsDTO
}
