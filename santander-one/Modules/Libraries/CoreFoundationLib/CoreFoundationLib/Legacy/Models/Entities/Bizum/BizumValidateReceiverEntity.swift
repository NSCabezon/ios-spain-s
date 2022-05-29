import SANLegacyLibrary

public struct BizumValidateReceiverEntity: DTOInstantiable {
    public let dto: BizumValidateReceiver

    public var identifier: String {
        return dto.identifier
    }
    public var beneficiaryAlias: String? {
        return dto.beneficiaryAlias
    }
    public var operationId: String {
        return dto.operationId
    }
    public var action: String {
        return dto.action
    }
    
    public init(_ dto: BizumValidateReceiver) {
        self.dto = dto
    }
}
