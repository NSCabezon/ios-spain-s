import Foundation
import CoreFoundationLib
import SANLegacyLibrary

struct FractionedPaymentsViewModel {
    var cardEntity: CardEntity?
    var fractionedPaymentMovements: [FractionedPaymentsDetailMovementsViewModel]
    
    var cardUrlString: String {
        guard let cardEntity = self.cardEntity else {
            return ""
        }
        return cardEntity.cardImageUrl()
    }

    var cardName: String {
        guard let cardEntity = self.cardEntity else {
            return ""
        }
        return cardEntity.getAliasCamelCase()
    }

    var cardTypeWithIban: String {
        guard let cardEntity = self.cardEntity,
              let cardType = self.type
        else {
            return ""
        }
        return cardType + " | " + cardEntity.shortContract
    }
}

private extension FractionedPaymentsViewModel {
    var type: String? {
        guard let cardEntity = self.cardEntity else {
            return ""
        }
        if cardEntity.isPrepaidCard {
            return localized("cardDetail_text_ecashCard")
        } else if cardEntity.isCreditCard {
            return localized("cardDetail_text_CreditCard")
        } else if cardEntity.isDebitCard {
            return localized("cardDetail_text_debitCard")
        }
        return nil
    }
}
