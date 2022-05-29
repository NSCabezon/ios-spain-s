

public struct ProductRangeDescriptorEntity: DTOInstantiable {
    public var dto: ProductRangeDescriptorDTO
    
    public init(_ dto: ProductRangeDescriptorDTO) {
        self.dto = dto
    }
    
    public var type: Int? {
        return Int(dto.type ?? "")
    }
    
    public var fromSubtype: Int? {
        return Int(dto.fromSubtype ?? "")
    }
    
    public var toSubtype: Int? {
        return Int(dto.toSubtype ?? "")
    }
    
    public func isInRange(productType: Int, productSubtype: Int) -> Bool {
        guard
            let type = type,
            let fromSubtype = fromSubtype,
            let toSubtype = toSubtype,
            type == productType else { return false }
        return (fromSubtype...toSubtype).contains(productSubtype)
    }
}
