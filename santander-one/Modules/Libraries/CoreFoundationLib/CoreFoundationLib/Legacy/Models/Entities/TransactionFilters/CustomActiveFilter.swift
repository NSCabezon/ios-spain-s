public protocol CustomActiveFilterProtocol {
    var literal: String { get }
    var accessibilityIdentifier: String { get }
}

public enum CoreActiveFilter: CustomActiveFilterProtocol {
    case cardPendingTransaction
    
    public var literal: String {
        switch self {
        case .cardPendingTransaction:
            return "cards_label_movPendingSettlement"
        }
    }
    
    public var accessibilityIdentifier: String {
        switch self {
        case .cardPendingTransaction:
            return "cards_label_movPendingSettlement"
        }
    }
}
