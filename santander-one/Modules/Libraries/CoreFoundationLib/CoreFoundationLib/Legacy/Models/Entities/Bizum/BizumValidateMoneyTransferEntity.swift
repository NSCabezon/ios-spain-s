import SANLegacyLibrary

public struct BizumValidateMoneyTransferEntity: DTOInstantiable {
    public let dto: BizumValidateMoneyTransferDTO

    public init(_ dto: BizumValidateMoneyTransferDTO) {
        self.dto = dto
    }

    public var transferInfo: BizumTransferInfoEntity {
        return BizumTransferInfoEntity(dto.transferInfo)
    }

    public var operationId: String {
        return dto.operationId
    }

    public var beneficiaryAlias: String? {
        return dto.beneficiaryAlias
    }
}
