import Foundation

public final class PullOffersRangesEntity: DTOInstantiable {
    public let dto: PullOffersConfigRangesDTO
    public var offer: OfferEntity?
    
    public init(_ dto: DTO) {
        self.dto = dto
    }
    
    public init(_ dto: DTO, offer: OfferEntity?) {
        self.dto = dto
        self.offer = offer
    }
    
    public var identifier: String? {
        return dto.identifier
    }
    
    public var greaterAndEqualThan: Int? {
        return Int(dto.greaterAndEqualThan ?? "")
    }
    
    public var lessThan: Int? {
        return Int(dto.lessThan ?? "")
    }
    
    public var title: String? {
        return dto.title
    }
        
    public var icon: String? {
        return dto.icon
    }
    
    public var offersId: [String]? {
        return dto.offersId
    }
}
