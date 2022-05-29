//

import Foundation

public struct BizumValidateMoneyTransferDTO: Codable {
    public let transferInfo: BizumTransferInfoDTO
    public let operationId: String
    public let beneficiaryAlias: String? // this field can be null for a non bizum client
    
    private enum CodingKeys: String, CodingKey {
        case transferInfo = "info"
        case operationId = "idOperacion"
        case beneficiaryAlias = "aliasBeneficiario"
    }
}
