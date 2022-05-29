//
//  BizumMoneyRequestMultiActionEntity.swift
//  Models
//
//  Created by Jose Ignacio de Juan Díaz on 03/12/2020.
//

import Foundation

public struct BizumMoneyRequestMultiActionEntity {
    public let id: String
    public let beneficiaryAlias: String?
    public let operationId: String
    public let action: String
}
