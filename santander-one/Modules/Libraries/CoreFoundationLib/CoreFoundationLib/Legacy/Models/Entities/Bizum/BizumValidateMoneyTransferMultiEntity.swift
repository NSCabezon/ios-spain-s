import SANLegacyLibrary

public class BizumValidateMoneyTransferMultiEntity: DTOInstantiable {
    public let dto: BizumValidateMoneyTransferMultiDTO

    public var transferInfo: BizumTransferInfoEntity {
        return BizumTransferInfoEntity(dto.transferInfo)
    }
    public var multiOperationId: String {
        return dto.multiOperationId
    }
    public var validationResponseList: [BizumValidateReceiverEntity] {
        return dto.validationResponseList.map({ BizumValidateReceiverEntity($0.self) })
    }

    required public init(_ dto: BizumValidateMoneyTransferMultiDTO) {
        self.dto = dto
    }
}
