//
//  LoadingTipEntity.swift
//  Models
//
//  Created by Luis Escámez Sánchez on 04/02/2020.
//

import Foundation

public final class LoadingTipEntity: DTOInstantiable {
    public let dto: LoadingTipDTO
    
    public var mainTitle: String {
        return dto.mainTitle ?? ""
    }
    public var title: String {
        return dto.title ?? ""
    }
    public var boldTitle: String {
        return dto.boldTitle ?? ""
    }
    public var subtitle: String {
        return dto.subtitle ?? ""
    }
    
    public init(_ dto: LoadingTipDTO) {
        self.dto = dto
    }
}
