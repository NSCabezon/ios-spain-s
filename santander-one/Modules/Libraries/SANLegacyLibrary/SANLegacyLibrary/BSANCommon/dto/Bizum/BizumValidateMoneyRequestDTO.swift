//
//  BizumValidateMoneyRequestDTO.swift
//  Account
//
//  Created by Jose Ignacio de Juan Díaz on 26/11/2020.
//

import Foundation

public struct BizumValidateMoneyRequestDTO: Codable {
    public let transferInfo: BizumTransferInfoDTO
    public let operationId: String
    public let beneficiaryAlias: String?
    
    private enum CodingKeys: String, CodingKey {
        case transferInfo = "info"
        case operationId = "idOperacion"
        case beneficiaryAlias = "aliasOrdenante"
    }
}
