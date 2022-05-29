import CoreDomain

public final class BannerEntity: DTOInstantiable {
    public let dto: BannerDTO
    
    public init(_ dto: BannerDTO) {
        self.dto = dto
    }
    
    public var height: CGFloat {
        return dto.height
    }
    
    public var width: Float {
        return dto.width
    }
    
    public var url: String {
        return dto.url
    }
}

extension BannerEntity: BannerRepresentable {}
