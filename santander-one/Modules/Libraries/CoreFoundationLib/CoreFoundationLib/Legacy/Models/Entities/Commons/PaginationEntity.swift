//
//  PaginationEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 08/10/2019.
//

import SANLegacyLibrary

/// Create a paginationEntity, be aware that if **dto** is needed the constructor with **PaginationDTO** must be used
public final class PaginationEntity {

    public let isEnd: Bool
    public let dto: PaginationDTO?
    
    public init(_ dto: PaginationDTO) {
        self.isEnd = dto.endList
        self.dto = dto
    }
    
    public init() {
        self.isEnd = true
        self.dto = nil
    }
}
