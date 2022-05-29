//

import Foundation
import PFM
import CoreFoundationLib
import CoreDomain

struct Constants {
    static let accountType = "ACCOUNT"
    static let cardType = "CARD"
    static let accountTransaction = "ACCOUNT_TRANSACTION"
    static let cardTransaction = "CARD_TRANSACTION"
}

class PfmHelper {
    
    private let userId: String
    private let maxMonths: Int
    
    init(userId: String, maxMonths: Int = 4) {
        self.userId = userId
        self.maxMonths = maxMonths
    }
    
    // MARK: - Public methods
    
    func getLastDateForAccount(account: AccountEntity, backwardDays: Int) -> Date? {
        let accountPfm = AccountPfm(account: account)
        guard let productId = accountPfm.ibanString else {
            return nil
        }
        return getLastDate(productId: productId, backwardDays: backwardDays)
    }
    
    func getLastDateForCard(card: CardEntity, backwardDays: Int) -> Date? {
        let cardPfm = CardPfm(card: card)
        guard let productId = cardPfm.pan else {
            return nil
        }
        return getLastDate(productId: productId, backwardDays: backwardDays)
    }
    
    func insertAccountMovements(account: AccountEntity, transactions: [AccountTransactionEntity]) {
        let accountPfm: AccountPfm = AccountPfm(account: account)
        guard !transactions.isEmpty, let productId = accountPfm.ibanString else {
            return
        }
        
        let type = Constants.accountTransaction
        let bankCode = accountPfm.bankCode
        let branchCode = accountPfm.branchCode
        let product = accountPfm.product
        let contractNumber = accountPfm.contractNumber
        let manager = DataBaseManager.shared
        transactions.forEach { transaction in
            let transactionPfm = AccountTransactionPfm(transaction: transaction)
            let dgo = transaction.dto.dgoNumber
            if let date = transactionPfm.operationDate {
                var transactionModel: TransactionModel
                var accountTransactionModel: AccountTransactionModel
                
                if (dgo?.terminalCode == nil || dgo?.terminalCode == "") &&
                    ((dgo?.number == "0" || dgo?.number == "00000000") || dgo?.number == nil) {
                    let productDB = manager.product.product(id: productId, userId: userId)
                    if let productDataBase = productDB, productDataBase.revision == 0 {
                        let randomID = gimmeRandomNumber()
                        transactionModel = TransactionModel(transactionType: type, id: randomID, productId: productId, userId: userId, date: date, amount: transactionPfm.amount, currency: transactionPfm.amountCurrency, description: transactionPfm.description, read: 0, bankCode: bankCode, branchCode: branchCode, product: product, contractnumber: contractNumber, annotationDate: transactionPfm.annotationDate, valueDate: transactionPfm.valueDate, transactionDay: transactionPfm.transactionDay, transactionNumber: transactionPfm.transactionNumber)
                            
                        accountTransactionModel = AccountTransactionModel(transaction: transactionModel, type: transactionPfm.transactionType, productSubtypeCode: transactionPfm.productSubtypeCode, terminalCode: transactionPfm.terminalCode, number: transactionPfm.dgoNumber, center: transactionPfm.dgoCenter, company: bankCode, balance: transactionPfm.balance)
                        
                        manager.transaction.insertTransaction(transaction: transactionModel)
                        manager.transaction.insertAccountTransaction(accountTransaction: accountTransactionModel)
                    }
                } else {
                    transactionModel = TransactionModel(transactionType: type, id: transactionPfm.dgo ?? "", productId: productId, userId: userId, date: date, amount: transactionPfm.amount, currency: transactionPfm.amountCurrency, description: transactionPfm.description, read: 0, bankCode: bankCode, branchCode: branchCode, product: product, contractnumber: contractNumber, annotationDate: transactionPfm.annotationDate, valueDate: transactionPfm.valueDate, transactionDay: transactionPfm.transactionDay, transactionNumber: transactionPfm.transactionNumber)
                    
                    accountTransactionModel = AccountTransactionModel(transaction: transactionModel, type: transactionPfm.transactionType, productSubtypeCode: transactionPfm.productSubtypeCode, terminalCode: transactionPfm.terminalCode, number: transactionPfm.dgoNumber, center: transactionPfm.dgoCenter, company: bankCode, balance: transactionPfm.balance)
                    
                    manager.transaction.insertTransaction(transaction: transactionModel)
                    manager.transaction.insertAccountTransaction(accountTransaction: accountTransactionModel)
                }
            }
        }
        manager.product.updateLastDateProduct(id: productId, userId: userId)
    }
    
    func insertCardMovements(card: CardEntity, transactions: [CardTransactionEntity]) {
        let cardPfm = CardPfm(card: card)
        guard !transactions.isEmpty, let productId = cardPfm.pan else {
            return
        }
        let type = Constants.cardTransaction
        let bankCode = cardPfm.bankCode
        let branchCode = cardPfm.branchCode
        let product = cardPfm.product
        let contractnumber = cardPfm.contractNumber
        let manager = DataBaseManager.shared
        transactions.forEach { transaction in
            let transactionPfm = CardTransactionPfm(cardTransaction: transaction)
            if let operationDate = transactionPfm.operationDate {
                let transactionModel = TransactionModel(transactionType: type, id: transactionPfm.pk, productId: productId, userId: userId, date: operationDate, amount: transactionPfm.amount, currency: transactionPfm.amountCurrency, description: transactionPfm.description, read: 0, bankCode: bankCode, branchCode: branchCode, product: product, contractnumber: contractnumber, annotationDate: transactionPfm.annotationDate, valueDate: operationDate, transactionDay: transactionPfm.transactionDay, transactionNumber: transactionPfm.transactionNumber)
                let cardTransactionModel = CardTransactionModel(transaction: transactionModel, balanceCode: transactionPfm.balanceCode)
                manager.transaction.insertTransaction(transaction: transactionModel)
                manager.transaction.insertCardTransaction(cardTransaction: cardTransactionModel)
            }
        }
        manager.product.updateLastDateProduct(id: productId, userId: userId)
    }
    
    func insertAccounts(accounts: [AccountEntity]) {
        let manager = DataBaseManager.shared
        accounts.forEach { account in
            let accountPfm = AccountPfm(account: account)
            if let productId = accountPfm.ibanString {
                if DataBaseManager.shared.product.product(id: productId, userId: userId) == nil {
                    let product = ProductModel(userId: userId,
                                               id: productId,
                                               type: Constants.accountType,
                                               lastUpdate: PfmDateUtil.defaultDate(monthsBefore: maxMonths),
                                               revision: 0)
                    manager.product.insertProduct(product: product)
                }
            }
        }
    }
    
    func insertCards(cards: [CardEntity]) {
        let manager = DataBaseManager.shared
        cards.forEach { card in
            let cardPfm = CardPfm(card: card)
            if let productId = cardPfm.pan {
                if DataBaseManager.shared.product.product(id: productId, userId: userId) == nil {
                    let product = ProductModel(userId: userId,
                                               id: productId,
                                               type: Constants.cardType,
                                               lastUpdate: PfmDateUtil.defaultDate(monthsBefore: maxMonths),
                                               revision: 0)
                    manager.product.insertProduct(product: product)
                }
            }
        }
    }
    
    func searchAccountTransactions(account: AccountEntity, searchText: String, fromDate: Date, toDate: Date? = nil) -> [AccountTransactionEntity] {
        let accountPfm = AccountPfm(account: account)
        guard let productId = accountPfm.ibanString else {
            return  []
        }
        let result = DataBaseManager.shared.transaction.accountTransactionsSearch(userId: userId, productId: productId, searchText: searchText, startDate: fromDate, endDate: toDate)
        let movements = result.map { accountTransactionModel -> AccountTransactionEntity in
            let pfm = AccountTransactionPfm(transactionModel: accountTransactionModel.transaction, account: account, accountTransationModel: accountTransactionModel)
            return pfm.transaction
        }
        return movements
    }
    
    func searchCardTransactions(card: CardEntity, searchText: String, fromDate: Date, endDate: Date? = nil) -> [CardMovement] {
        let cardPfm = CardPfm(card: card)
        guard let productId = cardPfm.pan else {
            return []
        }
        let result = DataBaseManager.shared.transaction.cardTransactionsSearch(userId: userId, productId: productId, searchText: searchText, startDate: fromDate, endDate: endDate)
        let movements = result.map { cardTransactionModel -> CardMovement in
            let pfm = CardTransactionPfm(transactionModel: cardTransactionModel.transaction, card: card, cardTransactionModel: cardTransactionModel)
            let cardMovement = CardMovement(transaction: pfm.transaction)
            return cardMovement
        }
        return movements
    }
    
    func searchAccountTransactions(account: AccountEntity, searchText: String, limit: Int, startDate: Date) -> [AccountTransactionEntity] {
        let accountPfm = AccountPfm(account: account)
        guard let productId = accountPfm.ibanString else { return  [] }
        let result = DataBaseManager.shared.transaction.lastAccountTransactionsSearch(userId: userId, productId: productId, startDate: startDate, searchText: searchText, limit: limit)
        let movements = result.map { accountTransactionModel -> AccountTransactionEntity in
            let pfm = AccountTransactionPfm(transactionModel: accountTransactionModel.transaction, account: account, accountTransationModel: accountTransactionModel)
            return pfm.transaction
        }
        return movements
    }
    
    func searchCardTransactions(card: CardEntity, searchText: String, limit: Int, startDate: Date) -> [CardMovement] {
        let cardPfm = CardPfm(card: card)
        guard let productId = cardPfm.pan else { return [] }
        let result = DataBaseManager.shared.transaction.lastCardTransactionsSearch(userId: userId, productId: productId, startDate: startDate, searchText: searchText, limit: limit)
        let movements = result.map { cardTransactionModel -> CardMovement in
            let pfm = CardTransactionPfm(transactionModel: cardTransactionModel.transaction, card: card, cardTransactionModel: cardTransactionModel)
            let cardMovement = CardMovement(transaction: pfm.transaction)
            return cardMovement
        }
        return movements
    }

    func searchLastsCardTransactions(card: CardEntity) -> [CardMovement] {
        let startDate = Date().dateByAdding(months: -1)
        let endDate = Date().lastDayOfCurrentMonth
        return searchCardTransactions(card: card, startDate: startDate, endDate: endDate)
    }
    
    func searchCardTransactions(card: CardEntity, startDate: Date, endDate: Date) -> [CardMovement] {
        let cardPfm = CardPfm(card: card)
        guard let productId = cardPfm.pan else {
            return []
        }
        let result = DataBaseManager.shared.transaction.lastCardTransactionsSearch(userId: userId, productId: productId, startDate: startDate, endDate: endDate)
        let movements = result.map { cardTransactionModel -> CardMovement in
            let pfm = CardTransactionPfm(transactionModel: cardTransactionModel.transaction, card: card, cardTransactionModel: cardTransactionModel)
            let cardMovement = CardMovement(transaction: pfm.transaction)
            return cardMovement
        }
        return movements
    }
    
    func unreadCardMovements(card: CardEntity, startDate: Date, limit: Int?) -> [CardMovement] {
        let cardPfm = CardPfm(card: card)
         guard let productId = cardPfm.pan else {
             return []
         }
        let result = DataBaseManager.shared.transaction.unreadCardTransactions(userId: userId, productId: productId, startDate: startDate, limit: limit)
        let movements = result.map { cardTransactionModel -> CardMovement in
            let pfm = CardTransactionPfm(transactionModel: cardTransactionModel.transaction, card: card, cardTransactionModel: cardTransactionModel)
            let cardMovement = CardMovement(transaction: pfm.transaction)
            return cardMovement
        }
        return movements
    }
    
    func unreadAccountMovements(account: AccountEntity, startDate: Date, limit: Int?) -> [AccountTransactionEntity] {
        let accountPfm = AccountPfm(account: account)
        guard let productId = accountPfm.ibanString else { return  [] }
        let result = DataBaseManager.shared.transaction.unreadAccountTransactions(userId: userId, productId: productId, startDate: startDate, limit: limit)
        let movements = result.map { accountTransactionModel -> AccountTransactionEntity in
            let pfm = AccountTransactionPfm(transactionModel: accountTransactionModel.transaction, account: account, accountTransationModel: accountTransactionModel)
                   return pfm.transaction
        }
        return movements
    }
    
    func getCountUnreadAccountMovements(account: AccountEntity) -> Int {
        let accountPfm = AccountPfm(account: account)
        guard let productId = accountPfm.ibanString else {
            return 0
        }
        return getCountUnreadMovements(productId: productId)
    }
    
    func setReadAllAccountMovements(account: AccountEntity) {
        let accountPfm = AccountPfm(account: account)
        guard let productId = accountPfm.ibanString else {
            return
        }
        setReadAllMovements(productId: productId)
    }
    
    func getCountUnreadCardMovements(card: CardEntity) -> Int {
        let cardPfm = CardPfm(card: card)
        guard let productId = cardPfm.pan else {
            return 0
        }
        return getCountUnreadMovements(productId: productId)
    }
    
    func setReadAllCardMovements(card: CardEntity) {
        let cardPfm = CardPfm(card: card)
        guard let productId = cardPfm.pan else {
            return
        }
        setReadAllMovements(productId: productId)
    }
    
    // MARK: - Private methods
    
    private func getCountUnreadMovements(productId: String) -> Int {
        return DataBaseManager.shared.transaction.newTransactionsCount(userId: userId, productId: productId)
    }

    private func setReadAllMovements(productId: String) {
        DataBaseManager.shared.transaction.setAllTransactionsRead(userId: userId, productId: productId)
    }
    
    func calcualtePfm(accounts: [AccountEntity], cards: [CardEntity], filter: [String], months: Int) -> [MonthlyBalanceRepresentable] {
        var productIds: [String] = []
        for account in accounts where account.isAccountHolder() {
            let accountPfm = AccountPfm(account: account)
            if let productId = accountPfm.ibanString {
                productIds.append(productId)
            }
        }
        for card in cards where card.isCardContractHolder && card.isCreditCard {
            let cardPfm = CardPfm(card: card)
            if let productId = cardPfm.pan {
                productIds.append(productId)
            }
        }
        var items: [MonthlyBalanceRepresentable] = []
        let date = Date()
        for i in -(months - 1)...0 {
            let monthDate = date.dateByAdding(months: i)
            let item = getPfm(productIds: productIds, filter: filter, month: monthDate)
            items.append(item)
        }
        return items
    }
    
    private func getLastDate(productId: String, backwardDays: Int) -> Date {
        let product = DataBaseManager.shared.product.product(id: productId, userId: userId)
        let date = product?.lastUpdate.dateByAdding(days: -backwardDays)
        return checkDate(date: date)
    }
    
    private func checkDate(date: Date?) -> Date {
        let now = Date()
        let maxMonth = now.dateByAdding(months: -maxMonths)
        let maxDate = maxMonth.firstDayOfCurrentMonth
        if let date = date, maxDate.compare(date) ==  ComparisonResult.orderedAscending {
            return date
        } else {
            return maxDate
        }
    }
    
    func cardExpensesCalculationTransaction(card: CardEntity) -> AmountEntity {
        let cardPfm = CardPfm(card: card)
        guard let productId = cardPfm.pan else {
            return AmountEntity(value: 0)
        }
        let expenses = DataBaseManager.shared.transaction.expensesMonth(userId: userId, productId: productId, filter: [], month: Date())
        
        return AmountEntity(value: expenses)
    }
    
    private func getPfm(productIds: [String], filter: [String], month: Date) -> MonthlyBalanceRepresentable {
        var expense: Decimal = 0.0
        var incomes: Decimal = 0.0

        for productId in productIds {
            expense += DataBaseManager.shared.transaction.expensesMonth(userId: userId, productId: productId, filter: filter, month: month)
            incomes += DataBaseManager.shared.transaction.incomeMonth(userId: userId, productId: productId, filter: filter, month: month)
        }
        return DefaultMonthlyBalance(date: month, expense: expense, income: incomes)
    }
    
    func gimmeRandomNumber() -> String {
        let group1 = String(gimmeRandom(from: 1_000, to: 9_999))
        let group2 = String(gimmeRandom(from: 1_000, to: 9_999))
        let group3 = String(gimmeRandom(from: 10, to: 99))
        let group4 = String(gimmeRandom(from: 10, to: 99))
        
        return group1 + group2 + group3 + group4
    }
    
    func gimmeRandom(from: Int? = nil, to: Int) -> Int {
        let start = from ?? 0
        var random = Int(arc4random_uniform(UInt32((to - start) + 1)))
        random += start
        
        return random
    }
    
    func accountTransactionsExcludingInternal(userId: String, account: AccountEntity, startDate: Date, endDate: Date, includeInternalTransfers: Bool) -> [AccountTransactionEntity] {
        let accountPfm = AccountPfm(account: account)
        guard let productId = accountPfm.ibanString else { return [] }
        let result = DataBaseManager.shared.transaction.accountTransactionsExcludingInternalTransfers(userId: userId, productId: productId, startDate: startDate, endDate: endDate, includeInternalTransfers: includeInternalTransfers)
        let movements = result.map { accountTransactionModel -> AccountTransactionEntity in
            let pfm = AccountTransactionPfm(transactionModel: accountTransactionModel.transaction, account: account, accountTransationModel: accountTransactionModel)
            return pfm.transaction
        }
        return movements
    }
}
