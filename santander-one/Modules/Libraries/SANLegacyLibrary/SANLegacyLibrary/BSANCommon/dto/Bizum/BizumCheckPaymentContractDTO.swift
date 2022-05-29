//

import Foundation

public struct BizumCheckPaymentContractDTO: Codable {
    public let center: CentroDTO
    public let subGroup: String
    public let contractNumber: String
    
    public init(center: CentroDTO, subGroup: String, contractNumber: String) {
        self.center = center
        self.subGroup = subGroup
        self.contractNumber = contractNumber
    }
    
    private enum CodingKeys: String, CodingKey {
        case center = "centro"
        case subGroup = "subgrupo"
        case contractNumber = "numerodecontrato"
    }
}
