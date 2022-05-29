import Foundation

public final class PullOffersBudgetRangesEntity: DTOInstantiable {
    public let dto: PullOffersConfigBudgetDTO
    public var offer: OfferEntity?
    public var currentBudget: PullOffersConfigCurrentEntity
    public var currentDay: PullOffersConfigCurrentEntity
    
    public init(_ dto: DTO) {
        self.dto = dto
        self.currentBudget = PullOffersConfigCurrentEntity(dto.currentSpentBudget)
        self.currentDay = PullOffersConfigCurrentEntity(dto.currentDay)
    }
    
    public init(_ dto: DTO, offer: OfferEntity?) {
        self.dto = dto
        self.offer = offer
        self.currentBudget = PullOffersConfigCurrentEntity(dto.currentSpentBudget)
        self.currentDay = PullOffersConfigCurrentEntity(dto.currentDay)
    }
    
    public var identifier: String? {
        return dto.identifier
    }
    
    public var title: String? {
        return dto.title
    }
        
    public  var icon: String? {
        return dto.icon
    }
    
    public var offersId: [String]? {
        return dto.offersID
    }
}

public final class PullOffersConfigCurrentEntity: DTOInstantiable {
    public let dto: PullOffersConfigCurrentBudgetDTO
    
    public init(_ dto: DTO) {
        self.dto = dto
    }
    
    public var greaterAndEqualThan: Int? {
        return Int(dto.greaterAndEqualThan)
    }
    
    public var lessThan: Int? {
        return Int(dto.lessThan ?? "")
    }
}
