import CoreFoundationLib

// MARK: - Constants 
public struct FractionablePurchaseDetailCarouselConstants {
    // MARK: Container
    static let estimatedHeight: CGFloat = 406
    static let collapsedHeight: CGFloat = 198
    // MARK: Constraints
    static let centerExpandableButtonColapsedHeight: CGFloat = 5
    static let centerExpandableButtonExpandedHeight: CGFloat = -10
    static let containerBottomDefaultHeightConstraint: CGFloat = 51
    static let containerBottomUpdatedHeightConstraint: CGFloat = 25
}

public enum FractionablePurchaseItemStatus {
    case loading
    case success
    case error
}

public final class FractionablePurchaseDetailConfiguration {
    let card: CardEntity
    let movementID: String
    let movements: [FinanceableMovementEntity]
    
    public init(card: CardEntity, movementID: String, movements: [FinanceableMovementEntity]) {
        self.card = card
        self.movementID = movementID
        self.movements = movements
    }
}
