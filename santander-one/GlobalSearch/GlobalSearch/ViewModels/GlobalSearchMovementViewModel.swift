//
//  GlobalSearchMovementViewModel.swift
//  GlobalSearch
//
//  Created by Luis Escámez Sánchez on 25/02/2020.
//

import Foundation
import CoreFoundationLib

struct GlobalSearchMovementViewModel {
    
    private let amount: AmountEntity?
    private let date: Date?
    private let concept: String?
    private let alias: String?
    private let productImageUrl: String?
    private let dependenciesResolver: DependenciesResolver
    private let searchedTerm: String
    let entity: Any
    
    internal init(amount: AmountEntity?, date: Date?, concept: String?, alias: String?, productImageUrl: String?, dependenciesResolver: DependenciesResolver, searchedTerm: String, entity: Any) {
        self.amount = amount
        self.date = date
        self.concept = concept
        self.alias = alias
        self.productImageUrl = productImageUrl
        self.dependenciesResolver = dependenciesResolver
        self.searchedTerm = searchedTerm
        self.entity = entity
    }
    
    var amountAttributedString: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        guard let amount = amount else { return nil }
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 16)
        return decorator.getFormatedCurrency()
    }
    
    var dateFormatted: LocalizedStylableText {
        guard let date = date else { return LocalizedStylableText(text: "", styles: .none) }
        let dateString =  dependenciesResolver.resolve(for: TimeManager.self)
            .toStringFromCurrentLocale(date: date, outputFormat: .d_MMM)?.uppercased() ?? ""
        if date.isDayInToday() {
            return localized("product_label_todayTransaction", [StringPlaceholder(.date, dateString)])
        } else {
            return LocalizedStylableText(text: dateString, styles: nil)
        }
    }
    
    var camelCasedConcept: NSAttributedString {
        guard let concept = concept else { return NSAttributedString() }
        return highlight(searchedTerm: searchedTerm, at: concept.camelCasedString.trim())
    }
    
    var camelcasedProductAlias: String {
        guard let alias = alias else { return "" }
        return alias.camelCasedString
    }
    
    var imageUrl: String? {
        return productImageUrl
    }
    
    var productId: String? {
        
        if let account = entity as? AccountTransactionWithAccountEntity {
            return account.accountEntity.productIdentifier
        }
        
        if let card = entity as? CardTransactionWithCardEntity {
            return card.cardEntity.productIdentifier
        }
        
        return nil
    }
}

private extension GlobalSearchMovementViewModel {
    
    func highlight(searchedTerm: String, at baseString: String) -> NSAttributedString {
        
        let ranges = baseString.ranges(of: searchedTerm.trim()).map { range -> NSRange in
            NSRange(range, in: baseString)
        }
        
        let attributed = NSMutableAttributedString(string: baseString)
        ranges.forEach {
            attributed.addAttribute(.backgroundColor, value: UIColor.lightYellow, range: $0)
        }
        
        return attributed
    }
}
