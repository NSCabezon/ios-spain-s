import SANLegacyLibrary

public struct BizumOperationMultiDetailEntity: DTOInstantiable {
    public let dto: BizumOperationMultipleListDetailDTO

    public init(_ dto: BizumOperationMultipleListDetailDTO) {
        self.dto = dto
    }
    
    public var date: Date? {
        return self.dto.dischargeDate
    }
    
    public var emmiterId: String? {
        return self.dto.emitterId
    }
    
    public var receptorId: [String] {
        return self.dto.operations.compactMap { $0.receptorId }
    }
    
    public var receptorAlias: [String] {
        return self.dto.operations.compactMap { $0.receptorAlias ?? "" }
    }
    
    public var amount: Double? {
        return self.dto.amount
    }
    
    public var concept: String? {
        return self.dto.concept
    }
    
    public var emitterAlias: String? {
        return self.dto.emitterAlias
    }

    public var numberOfOperations: Int {
        return operations.count
    }
    
    public var type: BizumOperationTypeEntity? {
        switch self.dto.type {
        case "C2eR":
            return .purchase
        case "C2CPull":
            return .request
        case "C2CPush":
            if (self.dto.operations.map { $0.receptorId?.contains("+999999999") == true }.contains(true) ||
                self.dto.operations.map { $0.receptorId?.contains("+34999999") == true }.contains(true)) {
                return .donation
            } else {
                return .send
            }
        default:
            return nil
        }
    }

    public var operationId: String? {
        return self.dto.opeartionId
    }

    public var receptorState: [String]? {
        return self.dto.operations.compactMap { $0.state }
    }

    public var operations: [BizumOperationMultiDetailItemEntity] {
        return self.dto.operations.compactMap { BizumOperationMultiDetailItemEntity($0) }
    }
    
    public var emitterIban: BizumIbanDTO? {
        return self.dto.emitterIban
    }
    
    public var emitterIbanPlain: String? {
        guard let country = emitterIban?.country ,
        let checkDigits = emitterIban?.checkDigits,
            let codbban = emitterIban?.codbban else { return nil }
        return country + checkDigits + codbban
    }
}
