import CoreFoundationLib

public enum CardControlDistributionType {
    case seeRecurringPaymentsList
    case seeSubscriptions
}

public final class CardControlDistributionConfiguration {
    var card: CardEntity?
    public init(card: CardEntity?) {
        self.card = card
    }
}
