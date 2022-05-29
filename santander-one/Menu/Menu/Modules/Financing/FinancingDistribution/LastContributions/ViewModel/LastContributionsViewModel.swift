//
//  LastContributionsViewModel.swift
//  Menu
//
//  Created by Ignacio González Miró on 01/09/2020.
//

import Foundation
import CoreFoundationLib

final class LastContributionsViewModel {
    // MARK: - Global properties
    var loans: [LastContributionsLoansEntity]?
    var cards: [LastContributionsCardsEntity]?
    var loan: LastContributionsLoansEntity?
    var card: LastContributionsCardsEntity?
    init(loans: [LastContributionsLoansEntity], cards: [LastContributionsCardsEntity]) {
        self.loans = loans
        self.cards = cards
    }
    
    // MARK: Cell configuration
    struct TableSettings {
        enum Sections: Int {
            case loans = 0
            case cards = 1
        }
    }
    
    // MARK: - Methods used in tableView
    func numberOfSections(_ isEmptyView: Bool) -> Int {
        return isEmptyView ? 2 : 1
    }
    
    func numberOfRows(_ isEmptyView: Bool, section: Int, viewModel: LastContributionsViewModel?) -> Int {
        return isEmptyView ? numberOfRowsInSection(section, viewModel: viewModel) : 1
    }
    
    // MARK: - Methods used in cells
    func loadFeeTitle(_ entity: LastContributionsCardsEntity) -> String {
        var feeTitle = ""
        switch entity.currentPaymentType {
        case .monthlyPayment:
            feeTitle = localized("generic_label_monthlyFee")
        case .fixedFee:
            feeTitle = localized("generic_label_fixedFee")
        case .deferredPayment:
            feeTitle = localized("generic_label_DeferFee")
        default:
            feeTitle = ""
        }
        return feeTitle.uppercased()
    }
    
    func amountAttributedText(_ amountDecimal: Decimal?) -> NSAttributedString {
        guard let amountValue = amountDecimal else { return NSAttributedString(string: "") }
        let decimalValue = NSDecimalNumber(decimal: amountValue).decimalValue
        let amountEntity = AmountEntity(value: decimalValue)
        let amountAtributed = self.formattedMoneyFrom(decimalValue, size: 22.0, decimalFont: 16.0, amountEntity: amountEntity)
        return amountAtributed
    }
    
    func loadFeeDescription(_ entity: LastContributionsCardsEntity) -> String? {
        guard let feeDetail = entity.feeDetail else { return nil }
        let feeDescription = self.getAmount(feeDetail)
        let feeDescriptionString = self.handleFeeDescription(feeDescription, entity: entity)
        return feeDescriptionString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension LastContributionsViewModel {
    // MARK: TableView
    func numberOfRowsInSection(_ section: Int, viewModel: LastContributionsViewModel?) -> Int {
        switch section {
        case TableSettings.Sections.loans.rawValue:
            return viewModel?.loans?.count ?? 0
        case TableSettings.Sections.cards.rawValue:
            return viewModel?.cards?.count ?? 0
        default:
            return 0
        }
    }
    
    // MARK: Cell
    func formattedMoneyFrom(_ amount: Decimal, negativeSign: Bool = false, size: CGFloat, decimalFont: CGFloat, amountEntity: AmountEntity?) -> NSAttributedString {
        guard var amountEntity = amountEntity else { return NSAttributedString() }
        if negativeSign { amountEntity = amountEntity.changedSign }
        let decorator = MoneyDecorator(amountEntity, font: UIFont.santander(family: .text, type: .regular, size: size), decimalFontSize: decimalFont)
        let formmatedDecorator = decorator.formatAsMillions()
        return formmatedDecorator ?? NSAttributedString()
    }
    
    func getAmount(_ amount: String) -> String {
        let regex = "(?:\\d+(?:\\.\\d*)?|\\.\\d+)"
        if let range = amount.range(of: regex, options: .regularExpression) {
            return String(amount[range])
        } else {
            return ""
        }
    }
    
    func handleFeeDescription(_ feeDescription: String, entity: LastContributionsCardsEntity) -> String {
        var feeDetailString = ""
        let amountString = self.getAmount(feeDescription)
        switch entity.currentPaymentType {
        case .fixedFee:
            guard let amountDecimal = amountString.stringToDecimal else { return "" }
            let amountEntity = AmountEntity(value: amountDecimal)
            let decorator = MoneyDecorator(amountEntity, font: UIFont.santander(family: .text, type: .bold, size: 16.0))
            let formmatedDecorator = decorator.formatZeroDecimalWithCurrencyDecimalFont()
            feeDetailString = formmatedDecorator.string
        case .deferredPayment:
            feeDetailString = localized("generic_label_percentage", [StringPlaceholder(.value, amountString)]).text
        default:
            break
        }
        return feeDetailString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
