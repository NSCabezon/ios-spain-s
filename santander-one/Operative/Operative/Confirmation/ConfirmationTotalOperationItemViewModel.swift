import CoreFoundationLib

public enum ConfirmationTotalOperationType {
    case customKey(String)
    case totalDefault
    
    var totalTitleKey: String {
        switch self {
        case .customKey(let title):
            return title
        case .totalDefault:
            return "confirmation_label_totalOperation"
        }
    }
}

public final class ConfirmationTotalOperationItemViewModel {
    public let amountEntity: AmountEntity
    private let type: ConfirmationTotalOperationType
    
    public init(amountEntity: AmountEntity, type: ConfirmationTotalOperationType = .totalDefault) {
        self.amountEntity = amountEntity
        self.type = type
    }
    
    public var totalTitleKey: String {
        return self.type.totalTitleKey
    }
}
