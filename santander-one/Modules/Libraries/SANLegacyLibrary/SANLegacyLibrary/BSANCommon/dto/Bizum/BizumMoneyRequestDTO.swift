//
//  BizumMoneyRequestDTO.swift
//
//  Created by Jose Ignacio de Juan Díaz on 26/11/2020.
//

import Foundation

public struct BizumMoneyRequestDTO: Codable {
    public let transferInfo: BizumTransferInfoDTO
    public let operationId: String
    
    private enum CodingKeys: String, CodingKey {
        case transferInfo = "info"
        case operationId = "idOperacion"
    }
}
