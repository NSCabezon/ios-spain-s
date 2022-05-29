//
//  BizumValidateMoneyRequestMultiDTO.swift
//
//  Created by Jose Ignacio de Juan Díaz on 26/11/2020.
//

import Foundation

public struct BizumValidateMoneyRequestMultiDTO: Codable {
    public let transferInfo: BizumTransferInfoDTO
    public let operationMultipleId: String
    public let listValidationResponses: BizumMultiValidationReponses
    
    private enum CodingKeys: String, CodingKey {
        case transferInfo = "info"
        case operationMultipleId = "idOperacionMultiple"
        case listValidationResponses = "listaRespuestaValidacion"
    }
}

public struct BizumMultiValidationReponses: Codable {
    public let validationResponses: [BizumMultiValidationReponse]
    
    private enum CodingKeys: String, CodingKey {
        case validationResponses = "respuestaValidacion"
    }
}

public struct BizumMultiValidationReponse: Codable {
    public let id: String
    public let beneficiaryAlias: String?
    public let operationId: String
    public let action: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "identificador"
        case beneficiaryAlias = "aliasBeneficiario"
        case operationId = "idOperacion"
        case action = "accion"
    }
}


