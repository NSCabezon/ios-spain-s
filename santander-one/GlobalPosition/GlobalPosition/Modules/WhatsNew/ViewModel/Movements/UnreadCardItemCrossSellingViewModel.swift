import Foundation
import CoreFoundationLib

final class UnreadCardItemCrossSellingViewModel: UnreadCrossSellingViewProtocol {
    private let crossSellingParams: CardsCTAParameters
    private let offers: [PullOfferLocation: OfferEntity]
    private let cardTransaction: CardTransactionWithCardEntity
    var crossSellingSelected: CrossSellingRepresentable?
    
    init(cardTransaction: CardTransactionWithCardEntity,
         crossSellingParams: CardsCTAParameters,
         offers: [PullOfferLocation: OfferEntity]) {
        self.cardTransaction = cardTransaction
        self.crossSellingParams = crossSellingParams
        self.offers = offers
    }
    
    var index: Int {
        guard let cardCrossSelling = self.crossSellingSelected as? CardsMovementsCrossSellingProperties else { return -1 }
        return crossSellingParams
            .cardsCrossSelling
            .firstIndex(of: cardCrossSelling) ?? -1
    }
    
    var isCrossSellingEnabled: Bool {
        guard self.crossSellingParams.crossSellingEnabled,
              let cardCrossSelling = getCardCrossSelling() else { return false }
        self.crossSellingSelected = cardCrossSelling
        return true
    }
    
    func getCardCrossSelling() -> CardsMovementsCrossSellingProperties? {
        let values = getCrossSellingWithCardValues()
        return CrossSellingBuilder(
            itemsCrossSelling: crossSellingParams.cardsCrossSelling,
            transaction: cardTransaction.cardTransactionEntity.description,
            amount: cardTransaction.cardTransactionEntity.amount?.value,
            crossSellingValues: values
        )
        .getCrossSelling()
    }
}

private extension UnreadCardItemCrossSellingViewModel {
    func getCrossSellingWithCardValues() -> CrossSellingValues {
        let cardValues = CardValues(
            isDebit: cardTransaction.cardEntity.isDebitCard,
            isCredit: cardTransaction.cardEntity.isCreditCard,
            isPrepaid: cardTransaction.cardEntity.isPrepaidCard
        )
        let values = CrossSellingValues(cardValues: cardValues)
        return values
    }
}

extension UnreadCardItemCrossSellingViewModel: AccountEasyPayChecker { }
