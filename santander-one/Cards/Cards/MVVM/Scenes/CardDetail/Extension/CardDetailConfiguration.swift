import Foundation
import CoreDomain

public final class CardDetailConfiguration {
    public var card: CardRepresentable
    public var cardDetail: CardDetailRepresentable
    public var cardAliasConfiguration: CardAliasConfiguration?
    public var isCardHolderEnabled: Bool = true
    public var prepaidCardHeaderElements: [PrepaidCardHeaderElements] = []
    public var debitCardHeaderElements: [DebitCardHeaderElements] = []
    public var creditCardHeaderElements: [CreditCardHeaderElements] = []
    public var isCardPANMasked: Bool = true
    public var cardPAN: String?
    public var cardDetailElements: [CardDetailDataType]?
    public var isShowCardPAN: Bool = false
    public var formatLinkedAccount: String?
    public var formatLinkeWithCreditCardAccountNumber: String?
    
    public init(card: CardRepresentable, cardDetail: CardDetailRepresentable) {
        self.card = card
        self.cardDetail = cardDetail
    }
}

public struct CardAliasConfiguration {
    var isChangeAliasEnabled: Bool
    var maxAliasLength: Int
    var regExValidatorString: CharacterSet
    
    public init(isChangeAliasEnabled: Bool,
                maxAliasLength: Int = 20,
                regExValidatorString: CharacterSet = .alias) {
        self.isChangeAliasEnabled = isChangeAliasEnabled
        self.maxAliasLength = maxAliasLength
        self.regExValidatorString = regExValidatorString
    }
}
