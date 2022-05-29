import SwiftyJSON

public struct InsuranceParticipantDTO: Codable, RestParser {
    public let participantType: ParticipantTypeDTO
    public let customerInd: String?
    public let customerId: String?
    public let documentType: String?
    public let documentNumber: String?
    public let name: String?
    public let surname1: String?
    public let surname2: String?
    public let birthDate: String?
    public let sex: String?
    public let address: String?
    public let province: String?
    public let town: String?
    public let phoneNumber: String?
    public let email: String?
    public let surveyStatus: String?

    public init(json: JSON) {
        let participantType = json["participantType"]
        self.participantType = ParticipantTypeDTO(id: participantType["id"].string, description: participantType["description"].string)
        self.customerInd = json["customerInd"].string
        self.customerId = json["customerId"].string
        self.documentType = json["documentType"].string
        self.documentNumber = json["documentNumber"].string
        self.name = json["name"].string
        self.surname1 = json["surname1"].string
        self.surname2 = json["surname2"].string
        self.birthDate = json["birthDate"].string
        self.sex = json["sex"].string
        self.address = json["address"].string
        self.province = json["province"].string
        self.town = json["town"].string
        self.phoneNumber = json["phoneNumber"].string
        self.email = json["email"].string
        self.surveyStatus = json["surveyStatus"].string
    }
}
