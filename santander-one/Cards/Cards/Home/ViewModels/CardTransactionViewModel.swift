//
//  LoanTransactionViewModel.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/29/19.
//

import Foundation
import CoreFoundationLib

final class CardTransactionViewModel {
    private let easyPaymentEnabled: Bool
    private let crossSellingEnabled: Bool
    private var crossSellingSelected: CardsMovementsCrossSellingProperties?
    let cardsCrossSelling: [CardsMovementsCrossSellingProperties]
    var actionNameCrossSelling: String?
    let transaction: CardTransactionEntityProtocol
    let minEasyPayAmount: Double?
    let card: CardEntity
    
    init(transaction: CardTransactionEntityProtocol,
         card: CardEntity,
         minEasyPayAmount: Double?,
         easyPaymentEnabled: Bool,
         crossSellingEnabled: Bool,
         cardsCrossSelling: [CardsMovementsCrossSellingProperties]) {
        self.transaction = transaction
        self.minEasyPayAmount = minEasyPayAmount
        self.card = card
        self.easyPaymentEnabled = easyPaymentEnabled
        self.crossSellingEnabled = crossSellingEnabled
        self.cardsCrossSelling = cardsCrossSelling
    }
    
    var title: String? {
        return self.transaction.description?.capitalized
    }
    
    var amountAttributeString: NSAttributedString? {
        guard let amount = self.transaction.amount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 16)
        return decorator.getFormatedCurrency()
    }
    
    var isEasyPayEnabled: Bool {
        guard easyPaymentEnabled,
              card.isCreditCard,
              let minEasyPayAmount = self.minEasyPayAmount,
              let value = self.transaction.amount?.value, value < 0.0
        else { return false }
        let amount = NSDecimalNumber(decimal: value)
        return abs(amount.doubleValue) >= minEasyPayAmount
    }
    
    var isCrossSellingEnabled: Bool {
        guard crossSellingEnabled,
              transaction.description != nil,
              let cardCrossSelling = getCardCrossSelling() else { return false }
        self.crossSellingSelected = cardCrossSelling
        self.actionNameCrossSelling = cardCrossSelling.actionNameCrossSelling
        return true
    }
    
    var indexCardCrossSelling: Int {
        guard let crossSelling = self.crossSellingSelected else { return -1 }
        return self.cardsCrossSelling.firstIndex(of: crossSelling) ?? -1
    }
    
    var isFractionLabelEnabled: Bool {
        guard !card.isBeneficiary &&
              transaction.type == .transaction
        else { return false }
        return isEasyPayEnabled
    }
    
    var titleForCrossSellingLabel: String? {
        return isCrossSellingEnabled ? actionNameCrossSelling : nil
    }
}

private extension CardTransactionViewModel {
    func getCardCrossSelling() -> CardsMovementsCrossSellingProperties? {
        let values = getCrossSellingWithCardValues()
        return CrossSellingBuilder(
            itemsCrossSelling: cardsCrossSelling,
            transaction: transaction.description,
            amount: transaction.amount?.value,
            crossSellingValues: values
        ).getCrossSelling()
    }
    
    func getCrossSellingWithCardValues() -> CrossSellingValues {
        let cardValues = CardValues(
            isDebit: card.isDebitCard,
            isCredit: card.isCreditCard,
            isPrepaid: card.isPrepaidCard
        )
        let values = CrossSellingValues(cardValues: cardValues)
        return values
    }
}
