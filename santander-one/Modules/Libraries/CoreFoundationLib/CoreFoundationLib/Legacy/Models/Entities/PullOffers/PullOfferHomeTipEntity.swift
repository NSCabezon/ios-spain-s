//
//  PullOfferHomeTipEntity.swift
//  Models
//
//  Created by César González Palomino on 29/07/2020.
//

import Foundation

public struct PullOfferHomeTipEntity: DTOInstantiable {
    public let dto: PullOfferHomeTipDTO
    
    public var title: String? {
        return dto.title
    }
    
    public var content: [PullOfferTipEntity]? {
        guard let content = dto.content else { return nil }
        
        return content.compactMap { PullOfferTipEntity($0) }
    }
    
    public init(_ dto: PullOfferHomeTipDTO) {
        self.dto = dto
    }
}
