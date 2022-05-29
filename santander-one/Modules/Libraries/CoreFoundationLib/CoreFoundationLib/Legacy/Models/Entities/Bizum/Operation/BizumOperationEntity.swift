import SANLegacyLibrary

public enum BizumOperationBasicType: String {
    case c2CPush = "C2CPush"
    case c2eR = "C2eR"
    case c2CPull = "C2CPull"
}

public enum BizumOperationTypeEntity {
    case purchase// C2eR
    case send// C2CPush
    case request// C2CPull
    case donation// C2CPush y +999999999XXXXX || +34999999999
}

public enum BizumOperationActionType: String {
    case refund = "DEVOLVER"
    case accept = "ACEPTAR"
    case reject = "DENEGAR"
    case cancel = "ANULAR"
}

public enum BizumOperationStateEntity: String {
    case pendingValidation = "PENDIENTEV"
    case validated = "VALIDADA"
    case accepted = "ACEPTADA"
    case rejected = "RECHAZADA"
    case back = "DEVUELTA"
    case pendingResponse = "PENDIENTER"
    case denied = "DENEGADA"
    case expired = "CADUCADA"
    case canceled = "CANCELADA"
    case void = "ANULADA"
    case pending = "PENDIENTE"
    case error = "ERROR"
    case pendingRegister = "PENDIENTEA"
    
    public var rawValueFormatted: String {
        return self.rawValue.prefix(1) + self.rawValue.dropFirst().lowercased()
    }
}

public final class BizumOperationEntity: DTOInstantiable {
    public let dto: BizumOperationDTO
    
    public init(_ dto: BizumOperationDTO) {
        self.dto = dto
    }
    
    public var receptorId: String? {
        return self.dto.receptorId
    }
    public var emitterId: String? {
        return self.dto.emitterId
    }
    public var operationId: String? {
        return self.dto.operationId
    }
    public var date: Date? {
        return self.dto.dischargeDate
    }
    public var emitterAlias: String? {
        return self.dto.emitterAlias
    }
    public var receptorAlias: String? {
        return self.dto.receptorAlias
    }
    public var concept: String? {
        return self.dto.concept
    }
    public var basicType: BizumOperationBasicType? {
        guard let type = self.dto.type else { return nil }
        return BizumOperationBasicType(rawValue: type)
    }
    public var type: BizumOperationTypeEntity? {
        switch basicType {
        case .c2eR:
            return .purchase
        case .c2CPull:
            return .request
        case .c2CPush:
            if self.dto.receptorId?.contains("+999999999") == true || self.dto.receptorId?.contains("+34999999") == true {
                return .donation
            } else {
                return .send
            }
        case .none:
            return nil
        }
    }
    public var state: String? {
        return self.dto.state
    }
    public var stateType: BizumOperationStateEntity? {
        guard let state = self.dto.state else {
            return nil
        }
        return BizumOperationStateEntity(rawValue: state)
    }
    public var amount: Double? {
        return self.dto.amount
    }
    public var isMultiple: Bool {
        return self.dto.fields?["IND_MULTIPLE"] == "1"
    }
    public var hasAttachment: Bool {
        return self.dto.fields?["CONTENIDO_ADICIONAL"] == "1"
    }
    public var receptorIban: String? {
        return self.dto.receptorIban?.codbban
    }
    
    public var availableActions: [BizumActionEntity]? {
        guard let actions = self.dto.actionList else { return nil}
        var availableActions = [BizumActionEntity]()
        actions.availableAction.forEach { (item) in
            if let optionalAction = BizumOperationActionType(rawValue: item.action) {
                availableActions.append(BizumActionEntity(action: optionalAction, expiry: item.expiry))
            }
        }
        return availableActions
    }
}
