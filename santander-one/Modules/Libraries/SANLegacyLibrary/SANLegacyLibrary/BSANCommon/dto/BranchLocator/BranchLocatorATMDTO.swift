//

import Foundation
protocol BranchLocatorBaseDTO: Codable {
    var code: String { get }
    var location: LocationDTO { get }
}
public struct BranchLocatorATMDTO: BranchLocatorBaseDTO {
    public let code: String
    public let location: LocationDTO
    public let entityCode: String
    public let name: String?
    public let poiStatus: PoiStatus
    public let distanceInKM: Double
    public let distanceInMiles: Double

    enum CodingKeys: String, CodingKey {
        case code, entityCode, name, poiStatus
        case location
        case distanceInKM = "distanceInKm"
        case distanceInMiles
    }
}
