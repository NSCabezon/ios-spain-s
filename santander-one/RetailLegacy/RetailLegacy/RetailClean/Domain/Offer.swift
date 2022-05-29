import SANLegacyLibrary
import CoreDomain
import CoreFoundationLib

struct Offer {
    public let dto: OfferDTO
    var id: String? {
        return dto.product.identifier
    }
    
    var action: OfferActionRepresentable? {
        return dto.product.action
    }
    
    var banners: [Banner] {
        return dto.product.banners.compactMap { Banner.createFromDTO($0) }
    }
    
    var bannersContracts: [Banner] {
        return dto.product.bannersContract.compactMap { Banner.createFromDTO($0) }
    }
    
    var transparentClosure: Bool {
        return dto.product.transparentClosure ?? false
    }
    
    var description: String? {
        return dto.product.description
    }
    
    init(offerDTO: OfferDTO) {
        dto = offerDTO
    }
}

extension Offer: LoginMessagesData {
    static var hash: String {
        return "PullOffer"
    }
}
