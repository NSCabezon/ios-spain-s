//
//  PullOfferBookmarkEntity.swift
//  Models
//
//  Created by David Gálvez Alonso on 27/07/2020.
//

public final class PullOfferBookmarkEntity: DTOInstantiable {
    public let dto: PullOffersConfigBookmarkDTO
    public var offer: OfferEntity?
    
    public init(_ dto: DTO) {
        self.dto = dto
    }
    
    public var title: String? {
        return dto.title
    }
    
    public var size: Int? {
        return Int(dto.size ?? "")
    }
    
    public var offersId: [String]? {
        return dto.offersId
    }
}
