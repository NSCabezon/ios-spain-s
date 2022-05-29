import SANLegacyLibrary

public struct CardMovementLocation: DTOInstantiable {
    public let dto: CardMovementLocationDTO
    
    public init(_ dto: CardMovementLocationDTO) {
        self.dto = dto
    }
    
    public var concept: String? {
        dto.concept
    }
    public var date: Date? {
        dto.date
    }
    public var address: String? {
        dto.address
    }
    public var location: String? {
        dto.location
    }
    public var postalCode: String? {
        dto.postalCode
    }
    public var amount: AmountEntity? {
        guard let amount = dto.amount else {
            return nil
        }
        return AmountEntity(value: amount)
    }
    public var latitude: Double? {
       dto.latitude
    }
    public var longitude: Double? {
        dto.longitude
    }
    public var category: String? {
        dto.category
    }
}
