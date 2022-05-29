import CoreDomain

public struct OfferDTO {
    public let product: OfferProductDTO
    
    public init(product: OfferProductDTO) {
        self.product = product
    }
}

extension OfferDTO: OfferRepresentable {
    public var pullOfferLocation: PullOfferLocationRepresentable? {
        return nil
    }
    
    public var bannerRepresentable: BannerRepresentable? {
        return product.banners.first
    }
    
    public var action: OfferActionRepresentable? {
        return product.action
    }
    
    public var id: String? {
        return product.identifier
    }
    
    public var transparentClosure: Bool {
        return product.transparentClosure ?? false
    }
    
    public var productDescription: String {
        return product.description ?? ""
    }
    
    public var identifier: String {
        return product.identifier
    }
    
    public var rulesIds: [String] {
        return product.rulesIds
    }
    
    public var startDateUTC: Date? {
        return product.startDateUTC
    }
    
    public var endDateUTC: Date? {
        return product.endDateUTC
    }
}
