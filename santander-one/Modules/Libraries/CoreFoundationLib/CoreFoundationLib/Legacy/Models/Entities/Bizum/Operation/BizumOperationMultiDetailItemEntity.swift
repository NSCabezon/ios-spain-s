import SANLegacyLibrary

public struct BizumOperationMultiDetailItemEntity: DTOInstantiable {
    public let dto: BizumOperationMultipleDetailDTO

    public init(_ dto: BizumOperationMultipleDetailDTO) {
        self.dto = dto
    }

    public var operationId: String? {
        return dto.opeartionId
    }
    public var receptorId: String? {
        return dto.receptorId
    }
    public var receptorAlias: String? {
        return dto.receptorAlias
    }
    public var state: String? {
        return dto.state
    }
}
