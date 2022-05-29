protocol BizumHistoricOperationEntityProtocol {
    var amount: Double? { get }
    var concept: String? { get }
    var emitterAlias: String? { get }
    var receptorAlias: [String?] { get }
    var emitterId: String? { get }
    var receptorId: [String?] { get }
    var numberOfPersons: Int { get }
    var type: BizumOperationTypeEntity? { get }
    var operationId: String? { get }
}

public enum BizumHistoricOperationEntity {
    case simple(operation: BizumOperationEntity)
    case multiple(operation: BizumOperationMultiDetailEntity)
    
    public var date: Date? {
        switch self {
        case .simple(let operation):
            return operation.date
        case .multiple(let operation):
            return operation.date
        }
    }
}

extension BizumHistoricOperationEntity: BizumHistoricOperationEntityProtocol {
    public var amount: Double? {
        switch self {
        case .simple(let operation):
            return operation.amount
        case .multiple(let operation):
            return operation.amount
        }
    }
    
    public var concept: String? {
        switch self {
        case .simple(let operation):
            return operation.concept
        case .multiple(let operation):
            return operation.concept
        }
    }
    
    public var emitterAlias: String? {
        switch self {
        case .simple(let operation):
            return operation.emitterAlias
        case .multiple(let operation):
            return operation.emitterAlias
        }
    }
    
    public var receptorAlias: [String?] {
        switch self {
        case .simple(operation: let operation):
            return [operation.receptorAlias]
        case .multiple(operation: let operation):
            return operation.receptorAlias
        }
    }
    
    public var numberOfPersons: Int {
        switch self {
        case .simple:
            return 1
        case .multiple(operation: let operation):
            return operation.numberOfOperations
        }
    }
    
    public var emitterId: String? {
        switch self {
        case .simple(operation: let operation):
            return operation.emitterId
        case .multiple(operation: let operation):
            return operation.emmiterId
        }
    }
    
    public var receptorId: [String?] {
        switch self {
        case .simple(operation: let operation):
            return [operation.receptorId]
        case .multiple(operation: let operation):
            return operation.receptorId
        }
    }
    
    public var type: BizumOperationTypeEntity? {
        switch self {
        case .simple(operation: let operation):
            return operation.type
        case .multiple(operation: let operation):
            return operation.type
        }
    }

    public var operationId: String? {
        switch self {
        case .simple(operation: let operation):
            return operation.operationId
        case .multiple(operation: let operation):
            return operation.operationId
        }
    }

    public var hasAttachment: Bool {
        switch self {
        case .simple(operation: let operation):
            return operation.hasAttachment
        case .multiple(operation: _):
            return false
        }
    }

    public var stateType: BizumOperationStateEntity? {
        switch self {
        case .simple(operation: let operation):
            return operation.stateType
        case .multiple(operation: _):
            return nil
        }
    }
    
    public var receptorState: [String]? {
        switch self {
        case .simple(operation: let operation):
            return [operation.state ?? ""]
        case .multiple(operation: let operation):
            return operation.receptorState
        }
    }

    public var operations: [BizumOperationMultiDetailItemEntity]? {
        switch self {
        case .simple:
            return nil
        case .multiple(operation: let operation):
            return operation.operations
        }
    }
    
    public var receptorIban: String? {
        switch self {
        case .simple(let operation):
            return operation.receptorIban
        case .multiple(_):
            return nil
        }
    }
    
    public var bizumOperationEntity: BizumOperationEntity? {
        switch self {
        case .simple(let operation):
            return operation
        case .multiple:
            return nil
        }
    }
}
