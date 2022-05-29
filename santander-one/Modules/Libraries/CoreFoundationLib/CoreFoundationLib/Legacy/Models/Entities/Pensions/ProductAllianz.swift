

public struct ProductAllianz: DTOInstantiable {
    public let dto: ProductAllianzDTO
    
    public init(_ dto: ProductAllianzDTO) {
        self.dto = dto
    }
    
    public var type: String? {
        return dto.type
    }
    
    public var fromSubtype: String? {
        return dto.fromSubtype
    }
    
    public var toSubtype: String? {
        return dto.toSubtype
    }
}
