import SANLegacyLibrary

public struct MultimediaCapacityEntity {
    public let dto: MultimediaCapacityDTO

    public init(_ dto: MultimediaCapacityDTO) {
        self.dto = dto
    }

    public var phone: String {
        return dto.phone
    }

    public var capacity: Bool {
        return dto.capacity
    }
}
