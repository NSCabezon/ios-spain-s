import SwiftyJSON

public struct InsuranceCoverageDTO: Codable, RestParser {
    public let name: String?
    public let insuredAmount: AmountDTO
    public let optionalInd: String?

    public init(json: JSON) {
        self.name = json["name"].string
        self.insuredAmount = AmountDTO.init(json: json["insuredAmount"])
        self.optionalInd = json["optionalInd"].string
    }
}
