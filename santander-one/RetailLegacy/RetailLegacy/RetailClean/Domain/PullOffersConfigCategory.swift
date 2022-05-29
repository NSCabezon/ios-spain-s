import Foundation

import CoreFoundationLib

struct PullOffersConfigCategory: ImageTitleCollectionProtocol {
    let categoryDTO: PullOffersConfigCategoryDTO
    let offersDTO: [OfferDTO]
    
    static func createFromDTO(_ dto: PullOffersConfigCategoryDTO?, _ offersDTO: [OfferDTO]) -> PullOffersConfigCategory? {
        if let dto = dto {
            return PullOffersConfigCategory(dto: dto, offersDTO: offersDTO)
        }
        return nil
    }
    
    private init(dto: PullOffersConfigCategoryDTO, offersDTO: [OfferDTO]) {
        categoryDTO = dto
        self.offersDTO = offersDTO
    }
    
    var id: String? {
        return categoryDTO.identifier
    }
    
    var text: String? {
        return categoryDTO.name
    }
    
    var icon: String? {
        return categoryDTO.iconRelativeURL
    }
    
    var absoluteUrl: String? {
        return nil
    }
    
    var offers: [Offer]? {
        return offersDTO.compactMap { Offer(offerDTO: $0) }
    }
}
