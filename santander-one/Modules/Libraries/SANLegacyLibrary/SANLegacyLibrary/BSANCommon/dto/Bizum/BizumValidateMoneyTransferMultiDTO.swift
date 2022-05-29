//

import Foundation

public struct BizumValidateMoneyTransferMultiDTO: Codable {
    public let transferInfo: BizumTransferInfoDTO
    public let multiOperationId: String
    public let validationResponseList: [BizumValidateReceiver]
    
    private enum CodingKeys: String, CodingKey {
        case transferInfo = "info"
        case multiOperationId = "idOperacionMultiple"
        case validationResponseList = "listaRespuestaValidacion"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        transferInfo = try values.decode(BizumTransferInfoDTO.self, forKey: .transferInfo)
        multiOperationId = try values.decode(String.self, forKey: .multiOperationId)
        // dict -> array
        let validationDict = try values.decode([String: [BizumValidateReceiver]].self, forKey: .validationResponseList)
        validationResponseList = validationDict["respuestaValidacion"] ?? [BizumValidateReceiver]()
    }
}

public struct BizumValidateReceiver: Codable {
    public let identifier: String
    public let beneficiaryAlias: String? // this field can be null for a non bizum client
    public let operationId: String
    public let action: String

    private enum CodingKeys: String, CodingKey {
        case identifier = "identificador"
        case beneficiaryAlias = "aliasBeneficiario"
        case operationId = "idOperacion"
        case action = "accion"
    }
}
