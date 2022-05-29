//
//  FHTransactionListRepresentable.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 5/4/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

protocol FHTransactionListRepresentable {
    var date: Date { get }
    var items: [FHTransactionListItemRepresentable] { get }
    func setDateFormatterFiltered() -> LocalizedStylableText
}

protocol FHTransactionListItemRepresentable {
    var title: String { get }
    var description: String { get }
    var moreInfo: String { get }
    var defatultImageName: String? { get }
    var urlImage: String? { get }
    var amount: AmountRepresentable { get }
}

final class FHTransactionList: FHTransactionListRepresentable {
    var date: Date
    var items: [FHTransactionListItemRepresentable] = []
    
    init() {
        self.date = Date()
        self.items = []
    }
    
    func setDateFormatterFiltered() -> LocalizedStylableText {
        let decorator = DateDecorator(self.date)
        return decorator.setDateFormatterTransactions()
    }
}

struct FHTransactionListItem: FHTransactionListItemRepresentable {
    let title: String
    let description: String
    let moreInfo: String
    let defatultImageName: String?
    let urlImage: String?
    let amount: AmountRepresentable
}

struct CategoryDetailParameters {
    let timeSelectorSelected: TimeSelectorRepresentable?
    let periodSelected: PeriodSelectorRepresentable?
    let categorySelected: CategoryRepresentable?
    let companiesWithProductsInfo: [FinancialHealthCompanyRepresentable]
    let productsSelected: [FinancialHealthProductRepresentable]?
}
