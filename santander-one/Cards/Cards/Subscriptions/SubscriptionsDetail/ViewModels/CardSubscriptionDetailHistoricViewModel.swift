//
//  CardSubscriptionDetailHistoricViewModel.swift
//  Cards
//
//  Created by Ignacio González Miró on 15/4/21.
//

import CoreFoundationLib

public struct CardSubscriptionDetailHistoricViewModel {
    var historicalEntity: CardSubscriptionHistoricalEntity
    
    public init(_ subscriptionHistoricalEntity: CardSubscriptionHistoricalEntity) {
        self.historicalEntity = subscriptionHistoricalEntity
    }
    
    // MARK: Historic VM Properties
    var amountAttributeString: NSAttributedString? {
        let amount = subscriptionAmount ?? AmountEntity(value: 0.0)
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 16.0)
        return decorator.getFormatedCurrency()
    }
    
    var subscriptionAmount: AmountEntity? {
        guard let amount = historicalEntity.amount,
              let amountValue = amount.value else {
            return nil
        }
        return AmountEntity(value: amountValue)
    }
    
    var businessName: String {
        historicalEntity.providerName
    }
    
    var dateString: String? {
        dateToString(date: historicalEntity.date, outputFormat: .EEEEdMMMMYYYY)?.camelCasedString
    }
    
    var isFractionable: Bool {
        historicalEntity.isFractionable
    }
    
    // MARK: SeeOptionsFractionable properties
    var transactionViewModel: CardListFinanceableTransactionViewModel?
    var isSeeFractionableOptionsExpanded: Bool = false
}
