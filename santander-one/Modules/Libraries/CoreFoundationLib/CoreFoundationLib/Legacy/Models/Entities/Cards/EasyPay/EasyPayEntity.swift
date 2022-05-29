//
//  EasyPayEntity.swift
//  Models
//
//  Created by Tania Castellano Brasero on 06/05/2020.
//

import SANLegacyLibrary

public struct EasyPayEntity {
    public let dto: EasyPayDTO
    
    public init(_ dto: EasyPayDTO) {
        self.dto = dto
    }
}
