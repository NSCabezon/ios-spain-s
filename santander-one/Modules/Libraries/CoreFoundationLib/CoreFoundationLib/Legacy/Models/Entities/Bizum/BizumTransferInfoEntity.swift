import SANLegacyLibrary

public struct BizumTransferInfoEntity: DTOInstantiable {
    public let dto: BizumTransferInfoDTO

    public init(_ dto: BizumTransferInfoDTO) {
        self.dto = dto
    }

    public var errorCode: String {
        return  dto.errorCode
    }

    public var codInfo: String? {
        return dto.codInfo
    }

    public var descInfo: String? {
        return dto.descInfo
    }
}
