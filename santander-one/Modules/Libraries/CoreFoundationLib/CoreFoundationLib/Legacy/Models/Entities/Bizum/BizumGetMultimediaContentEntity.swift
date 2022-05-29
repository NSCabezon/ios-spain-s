import SANLegacyLibrary

public struct BizumGetMultimediaContentEntity {
    public let dto: BizumGetMultimediaContentDTO

    public init(_ dto: BizumGetMultimediaContentDTO) {
        self.dto = dto
    }
    public var info: BizumTransferInfoDTO {
        return dto.info
    }
    public var additionalContentList: [AdditionalContentList] {
        return dto.additionalContentList
    }
    public var orderingUserId: String {
        return dto.orderingUserId
    }
    public var beneficiaryUserId: String {
        return dto.beneficiaryUserId
    }
}
