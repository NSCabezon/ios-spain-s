import Foundation
import CoreFoundationLib

enum SignPatternType: String {
    case SIGN01
    case SIGN02
}

final class UpdateSubscriptionOperativeData {
    var instaId: String?
    var cardEntity: CardEntity
    var cardSubscriptionEntity: CardSubscriptionEntityRepresentable
    var pattern: SignPatternType = .SIGN01
    var isActive: Bool?
    
    init(_ card: CardEntity, subscription: CardSubscriptionEntityRepresentable) {
        self.instaId = subscription.instaId
        self.cardEntity = card
        self.cardSubscriptionEntity = subscription
        self.isActive = subscription.active
    }
}
