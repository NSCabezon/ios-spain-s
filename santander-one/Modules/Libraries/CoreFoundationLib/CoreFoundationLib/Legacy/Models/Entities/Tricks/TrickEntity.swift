//
//  TrickEntity.swift
//  Models
//
//  Created by Tania Castellano Brasero on 28/04/2020.
//

import Foundation

public final class TrickEntity: DTOInstantiable {
    public let dto: TrickDTO
    
    public init(_ dto: TrickDTO) {
        self.dto = dto
    }
    
    public var textButton: String {
        return dto.textButton
    }
    
    public var icon: String {
        return dto.icon
    }
    
    public var title: String {
        return dto.title
    }
    
    public var description: String {
        return dto.description
    }
}
