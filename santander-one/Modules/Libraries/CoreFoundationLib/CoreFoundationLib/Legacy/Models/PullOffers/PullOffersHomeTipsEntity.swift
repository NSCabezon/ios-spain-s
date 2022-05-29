import Foundation

public final class PullOffersHomeTipsEntity: DTOInstantiable {
    public let dto: PullOffersHomeTipsDTO
    
    public init(_ dto: DTO) {
        self.dto = dto
    }
    
    public var title: String {
        self.dto.title
    }
    
    public var contents: [PullOffersHomeTipsContentEntity] {
        guard let content = self.dto.content else { return [] }
        return content.map { PullOffersHomeTipsContentEntity($0) }
    }
}

public final class PullOffersHomeTipsContentEntity: DTOInstantiable {
    public let dto: PullOffersHomeTipsContentDTO
    
    public init(_ dto: DTO) {
        self.dto = dto
    }
    
    public var title: String? {
        return dto.title
    }
    
    public var description: String? {
        return dto.desc
    }
    
    public  var icon: String? {
        return dto.icon
    }
    
    public var tag: String? {
        return dto.tag
    }
    
    public var offerId: String? {
        return dto.offerId
    }
    
    public var keyWords: [String]? {
        return dto.keyWords
    }
}
