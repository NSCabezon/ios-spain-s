//
//  BizumDefaultNGOEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 16/02/2021.
//

import Foundation

public final class BizumDefaultNGOEntity: DTOInstantiable {
    public var dto: BizumDefaultNGODTO
    
    public init(_ dto: BizumDefaultNGODTO) {
        self.dto = dto
    }
    
    public var identifier: String {
        return self.dto.identifier
    }
    
    public var name: String {
        return self.dto.name
    }
    
    public var alias: String {
        return self.dto.alias
    }
}
