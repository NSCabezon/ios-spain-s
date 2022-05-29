import SwiftyJSON

public struct InsuranceBeneficiariesListDTO: Codable, RestParser {
    
    public let beneficiaries: [InsuranceBeneficiaryDTO]
    
    public init(json: JSON) {
        self.beneficiaries = json["beneficiaries"].array?.map({ InsuranceBeneficiaryDTO(json: $0) }) ?? []
    }
}
