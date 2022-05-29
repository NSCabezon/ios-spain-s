//
//  LoadingTipsListDTO.swift
//  Models
//
//  Created by Luis Escámez Sánchez on 04/02/2020.
//

import Foundation

public final class LoadingTipsListEntity: DTOInstantiable {
    public let dto: LoadingTipsListDTO
    
    public init(_ dto: LoadingTipsListDTO) {
        self.dto = dto
    }
    
    public var loadingTipsEntities: [LoadingTipEntity] {
        guard let dtoTipsList = dto.loadingTips else { return [LoadingTipEntity]() }
        return dtoTipsList.map { LoadingTipEntity($0) }
    }
}
