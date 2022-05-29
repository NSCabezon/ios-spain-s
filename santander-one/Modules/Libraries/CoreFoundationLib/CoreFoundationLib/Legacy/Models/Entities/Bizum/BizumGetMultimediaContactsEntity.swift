import SANLegacyLibrary

public struct BizumGetMultimediaContactsEntity {
    public let dto: BizumGetMultimediaContactsDTO

    public init(_ dto: BizumGetMultimediaContactsDTO) {
        self.dto = dto
    }

    public var info: BizumTransferInfoDTO {
        return dto.info
    }

    public var contacts: [MultimediaCapacityEntity] {
        return dto.contacts.map { MultimediaCapacityEntity($0) }
    }
}
