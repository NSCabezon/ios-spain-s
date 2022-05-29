//
//  IncomeXpenseViewModel.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 09/06/2020.
//

import CoreFoundationLib

public final class IncomeExpenseViewModel {
    private var balanceTransactionsEntity: [BalanceTransactionEntity]
    private var selectedDate: Date
    private var sections: [Date] = [Date]()
    private var items: [Date: [BalanceItem]] = [:]
    private var totalAmount: Decimal?
    private var totalTransactions: Int?
    public var balanceType: AccountMovementsType {
        willSet {
            buildModelForBalance(newValue)
        }
    }
    public var numberOfSections: Int {
        sections.count
    }
    
    public func getHeaderAttributes() -> (title: NSAttributedString, subtitle: NSAttributedString) {
        let totalAmount: Decimal = self.totalAmount ?? 0
        let amountEntity = AmountEntity(value: totalAmount)
        let integerFont = UIFont.santander(family: .text, type: .bold, size: 28.0)
        let decorator = MoneyDecorator(amountEntity, font: integerFont, decimalFontSize: 22.0)
        let numberOfMovements = NSAttributedString(string: String(self.numberOfMovements()))
        let totalAmountDecorated = decorator.getFormatedCurrency() ?? NSAttributedString(string: amountEntity.getFormattedAmountAsMillions())
        let emptyDecorated = decorator.formatZeroDecimalWithCurrencyDecimalFont()
        let amount = amountEntity.value == 0 ? emptyDecorated : totalAmountDecorated
        return(numberOfMovements, amount)
    }
    
    public init(balanceTransactions: [BalanceTransactionEntity], selectedDate: Date, balanceType: AccountMovementsType) {
        self.balanceTransactionsEntity = balanceTransactions
        self.selectedDate = selectedDate
        self.balanceType = balanceType
        buildModelForBalance(balanceType)
    }
    
    public func rowsAtSection(_ section: Int) -> Int {
        guard section <= sections.count, sections.count > 0 else {
            return 0
        }
        let date = sections[section]
        let item = items[date]
        return item?.count ?? 0
    }
    
    public func itemAtIndexPath(_ indexPath: IndexPath) -> BalanceItem? {
        let bydate = sections[indexPath.section]
        if let item = items[bydate] {
            return item[indexPath.row]
        }
        return nil
    }
    
    public func sectionItemAt(_ index: Int) -> Date? {
        guard index <= sections.count, sections.count > 0 else {
            return nil
        }
        return sections[index]
    }
    
    public func numberOfMovements() -> Int {
        guard let index = totalTransactions else {
            return 0
        }
        return index
    }

    public func transactionFromBalanceItem(_ balanceItem: BalanceItem) -> (balanceTransactionsEntity: [AccountTransactionWithAccountEntity]?, selectedTransaction: AccountTransactionWithAccountEntity?) {
        let transactionsWithAccount = balanceTransactionsEntity.flatMap { balanceTransaction -> [AccountTransactionWithAccountEntity] in
            let transactionWithAccount = balanceTransaction.transactions.filter({ (balanceType == .expenses) ? $0.isNegativeAmount : !$0.isNegativeAmount}).compactMap({
                      AccountTransactionWithAccountEntity(accountTransactionEntity: $0, accountEntity: balanceTransaction.account)
            })
            return transactionWithAccount
        }
        
        guard
            let selectedTransactionWithAccount = transactionsWithAccount.filter({$0.accountTransactionEntity.dgo == balanceItem.transactionID}).first
        else {
            return (nil, nil)
        }
        
        return (transactionsWithAccount, selectedTransactionWithAccount)
    }
}

private extension IncomeExpenseViewModel {
    func buildModelForBalance(_ balanceType: AccountMovementsType) {
        var balanceCollection = [BalanceItem]()
        balanceTransactionsEntity.forEach { (response) in
            let transactions = response.transactions.filter({
                balanceType == .expenses ? $0.isNegativeAmount : !$0.isNegativeAmount
            })
            transactions.forEach({ item in
                let balanceItem = BalanceItem(concept: item.alias ?? "",
                                              account: response.account,
                                              amount: item.amount,
                                              date: item.operationDate ?? Date(),
                                              transactionID: item.dgo)
                balanceCollection.append(balanceItem)
            })
        }
        let empty: [Date: [BalanceItem]] = [:]
        let groupByDate = balanceCollection.reduce(into: empty, { balanceItem, cursor  in
            guard let cdate = dateGetCurrentLocaleDate(inputDate: cursor.date) else { return }
            let existing = balanceItem[cdate] ?? []
            balanceItem[cdate] = existing + [cursor]
        })
        let orderedSections = groupByDate.keys.sorted(by: {$0 > $1})
        items = groupByDate
        sections = Array(orderedSections)
        totalAmount = balanceCollection.reduce(0) {$0 + ($1.amount?.value ?? 0.0)}
        totalTransactions = balanceCollection.count
    }
}

public struct BalanceItem: Hashable {
    let concept: String
    let account: AccountEntity
    let amount: AmountEntity?
    let date: Date
    let transactionID: String
    var accountFormmated: String {
        "\(account.dto.alias ?? "") \(account.getIBANShort)"
    }
    
    public func amountAttributedText(_ totalAmount: Decimal) -> NSAttributedString {
        let amountEntity = AmountEntity(value: totalAmount)
        let integerFont = UIFont.santander(family: .text, type: .bold, size: 20.0)
        let decorator = MoneyDecorator(amountEntity, font: integerFont, decimalFontSize: 16.0)
        let totalAmountDecorated = decorator.getFormatedCurrency() ?? NSAttributedString(string: amountEntity.getFormattedAmountAsMillions())
        let emptyDecorated = decorator.formatZeroDecimalWithCurrencyDecimalFont()
        let amount = amountEntity.value == 0 ? emptyDecorated : totalAmountDecorated
        return amount
    }
    
    public static func == (lhs: BalanceItem, rhs: BalanceItem) -> Bool {
        return lhs.transactionID == rhs.transactionID
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(transactionID)
    }
}
