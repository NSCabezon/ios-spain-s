import CoreDomain

public class OfferEntity: DTOInstantiable {
    public let dto: OfferDTO
    public let location: PullOfferLocation?

    public var banner: BannerEntity? {
        guard let iosBanner = (dto.product.banners.first { $0.app.lowercased().contains("ios") }) else { return nil }
        return BannerEntity(iosBanner)
    }
    
    public var action: OfferActionRepresentable? {
        return dto.product.action
    }
    
    public var id: String? {
        return dto.product.identifier
    }
    
    public var transparentClosure: Bool {
        return dto.product.transparentClosure ?? false
    }
    
    public var productDescription: String {
        return dto.product.description ?? ""
    }
    
    required public init(_ dto: OfferDTO) {
        self.dto = dto
        self.location = nil
    }
    
    public init(_ dto: OfferDTO, location: PullOfferLocation) {
        self.dto = dto
        self.location = location
    }
}

extension OfferEntity: OfferRepresentable {
    public var identifier: String {
        return dto.identifier
    }
    
    public var bannerRepresentable: BannerRepresentable? {
        return self.banner
    }
    
    public var pullOfferLocation: PullOfferLocationRepresentable? {
        return self.location
    }
    
    public var rulesIds: [String] {
        return dto.rulesIds
    }
    
    public var startDateUTC: Date? {
        return dto.startDateUTC
    }
    
    public var endDateUTC: Date? {
        return dto.endDateUTC
    }
}
