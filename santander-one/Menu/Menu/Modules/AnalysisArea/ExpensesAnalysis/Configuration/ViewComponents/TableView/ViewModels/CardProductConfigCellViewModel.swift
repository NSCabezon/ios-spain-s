//
//  CardProductConfigCellViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 1/7/21.
//

import Foundation
import CoreFoundationLib

struct ExpenseAnalysisCardInfo {
    let alias: String
    let pan: String
    let isSantanderCard: Bool
    let imageUrl: String?
    let cardType: CardDOType
    let balance: AmountEntity
}

extension ExpenseAnalysisCardInfo: Equatable {
    static func == (lhs: ExpenseAnalysisCardInfo, rhs: ExpenseAnalysisCardInfo) -> Bool {
        lhs.alias == rhs.alias && lhs.pan == rhs.pan && lhs.isSantanderCard == rhs.isSantanderCard && lhs.cardType == rhs.cardType && lhs.balance == rhs.balance
    }
}

struct CardProductConfigCellViewModel {
    private let card: ExpenseAnalysisCardInfo
    private let baseURL: String?
    var isSelected: Bool
    let isLastCell: Bool
    
    init(card: ExpenseAnalysisCardInfo, baseURL: String?, isSelected: Bool, isLastCell: Bool) {
        self.card = card
        self.baseURL = baseURL
        self.isSelected = isSelected
        self.isLastCell = isLastCell
    }
    
    mutating func setIsCellSelected(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    var isSantanderCard: Bool {
        return self.card.isSantanderCard
    }
    
    var name: String {
        return self.card.alias
    }
    
    var pan: String {
        return self.card.pan
    }
    
    var showAvalaibleView: Bool {
        return self.card.cardType != .debit
    }
    
    var availableAmount: NSAttributedString? {
        let amount = self.card.balance
        let font = UIFont.santander(family: .text, type: .regular, size: 18)
        let moneyDecorator = MoneyDecorator(amount, font: font, decimalFontSize: 14)
        return moneyDecorator.getFormatedCurrency()
    }
    
    var cardIconURL: String? {
        guard let baseUrl = self.baseURL, let imageUrl = self.card.imageUrl else { return nil }
        return baseUrl + imageUrl
    }
    
    var bankIconUrl: String? {
        // TODO: - Account is needed?
        return nil
    }
}

extension CardProductConfigCellViewModel: Equatable {
    static func == (lhs: CardProductConfigCellViewModel, rhs: CardProductConfigCellViewModel) -> Bool {
        return lhs.card == rhs.card && lhs.isSelected == rhs.isSelected
    }
}
