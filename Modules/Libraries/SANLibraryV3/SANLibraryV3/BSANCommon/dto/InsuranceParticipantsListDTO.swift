import SwiftyJSON

public struct InsuranceParticipantsListDTO: Codable, RestParser {
    public let participants: [InsuranceParticipantDTO]
    
    public init(json: JSON) {
        self.participants = json["participants"].array?.map({ InsuranceParticipantDTO(json: $0) }) ?? []
    }
}
