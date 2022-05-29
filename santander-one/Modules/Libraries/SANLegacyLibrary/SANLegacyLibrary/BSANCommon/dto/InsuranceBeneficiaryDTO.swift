import SwiftyJSON

public struct InsuranceBeneficiaryDTO: Codable, RestParser {
    public let name: String?
    public let type: String?
    public let participationPercentage: String?

    public init(json: JSON) {
        self.name = json["name"].string
        self.type = json["type"].string
        self.participationPercentage = json["participationPercentage"].string
    }
}
