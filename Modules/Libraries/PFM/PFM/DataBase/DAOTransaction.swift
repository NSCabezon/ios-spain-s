import Foundation
import SQLite
import Logger
import CoreFoundationLib

// swiftlint:disable type_body_length
public class DAOTransaction: DAOProtocol {
    static let tableName = "table_transaction"
    static let transactionIdField = "transaction_id"
    static let transactionProductIdField = "transaction_id_product"
    static let transactionDateField = "transaction_date"
    static let transactionAmountField = "transaction_amount"
    static let transactionCurrencyField = "transaction_currency"
    static let transactionDescriptionField = "transaction_description"
    static let transactionReadField = "transaction_read"
    static let transactionAverageField = "transaction_average"
    
    static let transactionBankCodeField = "transaction_bank_code"
    static let transactionBranchCodeField = "transaction_branch_code"
    static let transactionProductField = "transaction_product"
    static let transactionContractnumberField = "transaction_contract_number"
    static let transactionAnnotationDateField = "transaction_annotation_date"
    static let transactionValueDateField = "transaction_value_date"
    static let transactionDayField = "transaction_day"
    static let transactionNumberField = "transaction_number"
    static let transactionDescriptionVirtualIdField = "transaction_description_virtual_table_id"

    private let dbm: DataBaseManager

    private var transactionTable: Table
    private var transactionId: SQLite.Expression<String>
    private var transactionProductId: SQLite.Expression<String>
    private var transactionUserId: SQLite.Expression<String>
    private var transactionDate: SQLite.Expression<Date>
    private var transactionAmount: SQLite.Expression<Int64>
    private var transactionCurrency: SQLite.Expression<String>
    private var transactionDescription: SQLite.Expression<String>
    private var transactionRead: SQLite.Expression<Int>
    
    private var transactionBankCode: SQLite.Expression<String>
    private var transactionBranchCode: SQLite.Expression<String>
    private var transactionProduct: SQLite.Expression<String>
    private var transactionContractnumber: SQLite.Expression<String>
    private var transactionAnnotationDate: SQLite.Expression<Date>
    private var transactionValueDate: SQLite.Expression<Date>
    private var transactionDay: SQLite.Expression<String>
    private var transactionNumber: SQLite.Expression<String>
    private var transactionDescriptionVirtualId: SQLite.Expression<Int>
    
    private var productTable: Table
    private var productId: SQLite.Expression<String>
    private var productUserId: SQLite.Expression<String>
    private var descriptionTable: VirtualTable
    private var descriptionRowId: SQLite.Expression<Int>
    
    private let cardTransaction: DAOCardTransaction
    private let accountTransaction: DAOAccountTransaction
    
    public required init(dbm: DataBaseManager) {
        self.dbm = dbm
        accountTransaction = DAOAccountTransaction(dbm: dbm)
        cardTransaction = DAOCardTransaction(dbm: dbm)

        transactionTable = Table(DAOTransaction.tableName)
        transactionId = SQLite.Expression<String>(DAOTransaction.transactionIdField)
        transactionProductId = SQLite.Expression<String>(DAOTransaction.transactionProductIdField)
        transactionUserId = SQLite.Expression<String>(DAOProduct.productUserIdField)
        transactionDate = SQLite.Expression<Date>(DAOTransaction.transactionDateField)
        transactionAmount = SQLite.Expression<Int64>(DAOTransaction.transactionAmountField)
        transactionCurrency = SQLite.Expression<String>(DAOTransaction.transactionCurrencyField)
        transactionDescription = SQLite.Expression<String>(DAOTransaction.transactionDescriptionField)
        transactionRead = SQLite.Expression<Int>(DAOTransaction.transactionReadField)
        
        transactionBankCode = SQLite.Expression<String>(DAOTransaction.transactionBankCodeField)
        transactionBranchCode = SQLite.Expression<String>(DAOTransaction.transactionBranchCodeField)
        transactionProduct = SQLite.Expression<String>(DAOTransaction.transactionProductField)
        transactionContractnumber = SQLite.Expression<String>(DAOTransaction.transactionContractnumberField)
        transactionAnnotationDate = SQLite.Expression<Date>(DAOTransaction.transactionAnnotationDateField)
        transactionValueDate = SQLite.Expression<Date>(DAOTransaction.transactionValueDateField)
        transactionDay = SQLite.Expression<String>(DAOTransaction.transactionDayField)
        transactionNumber = SQLite.Expression<String>(DAOTransaction.transactionNumberField)
        transactionDescriptionVirtualId = SQLite.Expression<Int>(DAOTransaction.transactionDescriptionVirtualIdField)
        
        productTable = Table(DAOProduct.tableName)
        productId = SQLite.Expression<String>(DAOProduct.productIdField)
        productUserId = SQLite.Expression<String>(DAOProduct.productUserIdField)
        descriptionTable = VirtualTable(DAODescription.tableName)
        descriptionRowId = SQLite.Expression<Int>(DAODescription.rowIdField)
    }
    
    func createTable() -> String {
        dbm.run(cardTransaction.createTable())
        dbm.run(accountTransaction.createTable())

        return transactionTable.create(ifNotExists: true) { t in
            t.column(transactionId)
            t.column(transactionProductId)
            t.column(transactionUserId)
            t.column(transactionDate)
            t.column(transactionAmount)
            t.column(transactionCurrency)
            t.column(transactionDescription)
            t.column(transactionRead, defaultValue:0)
            t.column(transactionBankCode)
            t.column(transactionBranchCode)
            t.column(transactionProduct)
            t.column(transactionContractnumber)
            t.column(transactionAnnotationDate)
            t.column(transactionValueDate)
            t.column(transactionDay)
            t.column(transactionNumber)
            t.column(transactionDescriptionVirtualId)
            t.primaryKey(transactionId, transactionProductId, transactionUserId)
            t.foreignKey(transactionProductId, references: productTable, productId, delete: .cascade)
            t.foreignKey(transactionUserId, references: productTable, productUserId, delete: .cascade)
            t.foreignKey(transactionDescriptionVirtualId, references: descriptionTable, descriptionRowId, delete: .cascade)
        }
    }
    
    func createIndex() -> String {
        return transactionTable.createIndex(transactionProductId.asc, transactionUserId.asc, ifNotExists: true)
    }
    
    func insertTransactionQuery(transaction: TransactionModel) -> Insert {
        return transactionTable.insert(or: OnConflict.ignore,
            transactionId <- transaction.id,
            transactionProductId <- transaction.productId,
            transactionUserId <- transaction.userId,
            transactionDate <- transaction.date,
            transactionAmount <- transaction.amount,
            transactionCurrency <- transaction.currency,
            transactionDescription <- transaction.description,
            transactionRead <- transaction.read,
            transactionBankCode <- transaction.bankCode,
            transactionBranchCode <- transaction.branchCode,
            transactionProduct <- transaction.product,
            transactionContractnumber <- transaction.contractnumber,
            transactionAnnotationDate <- transaction.annotationDate,
            transactionValueDate <- transaction.valueDate,
            transactionDay <- transaction.transactionDay,
            transactionNumber <- transaction.transactionNumber,
            transactionDescriptionVirtualId <- 1
        )
    }
    
    func selectTransactionQuery(id: String, userId: String) -> QueryType {
        return transactionTable.filter(transactionId == id && transactionUserId == userId)
    }
    
    func selectTransactionsQuery(userId: String, productId: String) -> QueryType {
        return transactionTable.filter(transactionUserId == userId && transactionProductId == productId)
    }
    
    public func insertTransaction(transaction: TransactionModel) {
        dbm.run(insertTransactionQuery(transaction: transaction))
    }
    
    public func insertTransaction(transactions: [TransactionModel]) {
        for transaction in transactions {
            dbm.run(insertTransactionQuery(transaction: transaction))
        }
    }
    
    public func insertAccountTransaction(accountTransaction: AccountTransactionModel) {
        self.accountTransaction.insertAccountTransaction(accountTransaction: accountTransaction)
    }
    
    public func insertAccountTransaction(accountTransactions: [AccountTransactionModel]) {
        self.accountTransaction.insertAccountTransaction(accountTransactions: accountTransactions)
    }
    
    public func insertCardTransaction(cardTransaction: CardTransactionModel) {
        self.cardTransaction.insertCardTransaction(cardTransaction: cardTransaction)
    }
    
    public func insertCardTransaction(cardTransactions: [CardTransactionModel]) {
        self.cardTransaction.insertCardTransaction(cardTransactions: cardTransactions)
    }
    
    public func transaction(id: String, userId: String) -> TransactionModel? {
        do {
            let rows = try dbm.prepare(selectTransactionQuery(id: id, userId: userId))
            let result = rows.map({ (row) -> TransactionModel in
                return transactionModel(row: row)
            }).first
            return result
        } catch let error {
            logError(error)
        }
        return nil
    }
    
    public func updateTransaction(transaction: TransactionModel) {
        let transactionToUpdate = selectTransactionQuery(id: transaction.id, userId: transaction.userId)
        dbm.run(transactionToUpdate.update([transactionAmount <- transaction.amount,
                                            transactionCurrency <- transaction.currency,
                                            transactionDescription <- transaction.description,
                                            transactionRead <- transaction.read]))
    }
    
    public func deleteTransaction(transactionId: String, userId: String) {
        let transactionToUpdate = selectTransactionQuery(id: transactionId, userId: userId)
        dbm.run(transactionToUpdate.delete())
    }
    
    public func deleteCardTransaction(transactionId: String, userId: String) {
        cardTransaction.deleteTransaction(transactionId: transactionId, userId: userId)
    }
    
    public func deleteAllTransactions() {
        dbm.run(transactionTable.delete())
    }
    
    public func newTransactionsCount(userId: String, productId: String) -> Int {
        let query = transactionTable.filter(transactionUserId == userId && transactionProductId == productId && transactionRead == 0).count
        do {
            guard let result = try dbm.scalar(query) else {
                return 0
            }
            return result
        } catch let error {
            logError(error)
        }
        return 0
    }
    
    public func unreadAccountTransactions(userId: String, productId: String, startDate: Date, limit: Int?) -> [AccountTransactionModel] {
        do {
            let rows = try dbm.prepare(prepareUnreadAccountTransactionsQuery(userId: userId, productId: productId, startDate: startDate, limit: limit))
            let result = rows.map({ (row) -> AccountTransactionModel in
                return accountTransaction.accountTransaction(row: row, transaction: transactionModel(row: row))!
            })
            return result
        } catch {
            logError(error)
            return []
        }
    }
    
    public func unreadCardTransactions(userId: String, productId: String, startDate: Date, limit: Int?) -> [CardTransactionModel] {
        do {
            let rows = try dbm.prepare(prepareUnreadCardTransactionsQuery(userId: userId, productId: productId, startDate: startDate, limit: limit))
            let result = rows.map({ (row) -> CardTransactionModel in
                return cardTransaction.cardTransaction(row: row, transaction: transactionModel(row: row))
            })
            return result
        } catch {
            logError(error)
            return []
        }
    }
    
    public func setAllTransactionsRead(userId: String, productId: String) {
        let query = selectTransactionsQuery(userId: userId, productId: productId)
        dbm.run(query.update(transactionRead <- 1))
    }
    
    public func expensesMonth(userId: String, productId: String, filter: [String], month: Date) -> Decimal {
        let startDate = month.firstDayOfCurrentMonth
        let endDate = month.lastDayOfCurrentMonth
        let result = rawAverageIncome(userId: userId, productId: productId, startDate:startDate, endDate:endDate, months: 1, filter: filter)
        return result
    }
    
    public func incomeMonth(userId: String, productId: String, filter: [String], month: Date) -> Decimal {
        let startDate = month.firstDayOfCurrentMonth
        let endDate = month.lastDayOfCurrentMonth
        let result = rawAverageIncome(userId: userId, productId: productId, startDate:startDate, endDate:endDate, months: 1, filter: filter, income: true)
        return result
    }
    
    private func rawAverageIncome(userId: String, productId: String, startDate: Date, endDate: Date, months: Int, filter: [String], income: Bool = false) -> Decimal {
        var result: Decimal = 0.0
        let sqlLiteSentence = prepareRAWQuery(filters: filter, income: income)
        let bindings: [Binding] = [months, productId, userId, startDate.toFormattedPOSIXDateClean(), endDate.toFormattedPOSIXDateClean(), "EUR"]
        
        do {
            guard let sum = try dbm.scalar(sqlLiteSentence, bindings) as? Int64 else {
                return result
            }
            result = Decimal(sum) / Decimal (pow(10.0, Double(2)))
            
            return abs(result)
        } catch let error {
            logError(error)
        }
        
        return result
    }
    
    public func accountTransactionsExcludingInternalTransfers(userId: String, productId: String, startDate: Date, endDate: Date, includeInternalTransfers: Bool = true) -> [AccountTransactionModel] {
        let sqlLiteSentence = prepareRAWQueryForAccountMovementsWithFilters(includeInternalTransfers: includeInternalTransfers)
        let bindings: [Binding] = [productId,
                                   userId,
                                   startDate.toFormattedPOSIXDateClean(),
                                   endDate.toStringDate(),
                                   "EUR"]
        do {
            let query = try dbm.prepare(sqlLiteSentence, bindings: bindings)
            var results = [AccountTransactionModel]()
            while let row = query.next() {
                let rowValues = row.compactMap({$0})
                if let transaction = transactionModel(rows: rowValues), let accountTransaction = accountTransaction.accountTransactionModel(rows: rowValues, transactionModel: transaction) {
                    results.append(accountTransaction)
                }
            }
            return results
        } catch {
            logError(error)
            return []
        }
    }
    
    public func accountTransactionsSearch(userId: String, productId: String, searchText: String, startDate: Date, endDate: Date? = nil) -> [AccountTransactionModel] {
        do {
            let rows = try dbm.prepare(prepareSearchAccountTransactionsQuery(userId: userId, productId: productId, searchText: searchText, startDate: startDate, endDate: endDate ?? Date()))
            let result = rows.map({ (row) -> AccountTransactionModel in
               return accountTransaction.accountTransaction(row: row, transaction: transactionModel(row: row))!
            })
            return result
        } catch let error {
            logError(error)
        }
        return []
    }
    
    public func cardTransactionsSearch(userId: String, productId: String, searchText: String, startDate: Date, endDate: Date? = nil) -> [CardTransactionModel] {
        do {
            let rows = try dbm.prepare(prepareSearchCardTransactionsQuery(userId: userId, productId: productId, searchText: searchText, startDate: startDate, endDate: endDate ?? Date()))
            let result = rows.map({ (row) -> CardTransactionModel in
                return cardTransaction.cardTransaction(row: row, transaction: transactionModel(row: row))
            })
            return result
        } catch let error {
            logError(error)
        }
        return []
    }
    
    public func lastCardTransactionsSearch(userId: String, productId: String, startDate: Date, endDate: Date) -> [CardTransactionModel] {
        do {
            let rows = try dbm.prepare(prepareSearchLastCardTransactionsQuery(userId: userId, productId: productId, startDate: startDate, endDate: endDate))
            let result = rows.map({ (row) -> CardTransactionModel in
                return cardTransaction.cardTransaction(row: row, transaction: transactionModel(row: row))
            })
            return result
        } catch let error {
            logError(error)
        }
        return []
    }
    
    public func lastAccountTransactionsSearch(userId: String, productId: String, startDate: Date, searchText: String, limit: Int) -> [AccountTransactionModel] {
        do {
            let rows = try dbm.prepare(prepareSearchAccountTransactionsQuery(userId: userId, productId: productId, startDate: startDate, searchText: searchText, limit: limit))
            let result = rows.map({ (row) -> AccountTransactionModel in
                return accountTransaction.accountTransaction(row: row, transaction: transactionModel(row: row))!
            })
            return result
        } catch let error {
            logError(error)
        }
        return []
    }
    
    public func lastCardTransactionsSearch(userId: String, productId: String, startDate: Date, searchText: String, limit: Int) -> [CardTransactionModel] {
        do {
            let rows = try dbm.prepare(prepareSearchCardTransactionsQuery(userId: userId, productId: productId, startDate: startDate, searchText: searchText, limit: limit))
            let result = rows.map({ (row) -> CardTransactionModel in
                return cardTransaction.cardTransaction(row: row, transaction: transactionModel(row: row))
            })
            return result
        } catch let error {
            logError(error)
        }
        return []
    }
    
    func prepareSearchAccountTransactionsQuery(userId: String, productId: String, searchText: String, startDate: Date, endDate: Date) -> Table {
        
        let table = transactionTable.join(accountTransaction.accountTransactionTable,
                                     on: transactionId == accountTransaction.accountTransactionId
                                        && transactionProductId == accountTransaction.accountTransactionProductId
                                        && transactionUserId == accountTransaction.accountTransactionUserId
                                        && transactionProductId == productId
                                        && transactionUserId == userId
                                        && transactionDescription.like("%\(searchText.uppercased())%")
                                        && transactionDate >= startDate
                                        && transactionDate <= endDate
        ).order(transactionDate.desc)
        return table
    }
    
    func prepareSearchCardTransactionsQuery(userId: String, productId: String, searchText: String, startDate: Date, endDate: Date) -> Table {
        
        let table = transactionTable.join(cardTransaction.cardTransactionTable,
                                          on: transactionId == cardTransaction.cardTransactionId
                                            && transactionProductId == cardTransaction.cardTransactionProductId
                                            && transactionUserId == cardTransaction.cardTransactionUserId
                                            && transactionProductId == productId
                                            && transactionUserId == userId
                                            && transactionDescription.like("%\(searchText.uppercased())%")
                                            && transactionDate >= startDate
                                            && transactionDate <= endDate
        ).order(transactionDate.desc)
        return table
    }
    
    func prepareSearchLastCardTransactionsQuery(userId: String, productId: String, startDate: Date, endDate: Date) -> Table {
        
        let table = transactionTable.join(cardTransaction.cardTransactionTable,
                                          on: transactionId == cardTransaction.cardTransactionId
                                            && transactionProductId == cardTransaction.cardTransactionProductId
                                            && transactionUserId == cardTransaction.cardTransactionUserId
                                            && transactionProductId == productId
                                            && transactionUserId == userId
                                            && transactionDate >= startDate
                                            && transactionDate <= endDate
        ).order(transactionDate.desc)
        return table
    }
    
    func prepareSearchAccountTransactionsQuery(userId: String, productId: String, startDate: Date, searchText: String, limit: Int) -> Table {
        
        let table = transactionTable.join(accountTransaction.accountTransactionTable,
                                     on: transactionId == accountTransaction.accountTransactionId
                                        && transactionProductId == accountTransaction.accountTransactionProductId
                                        && transactionUserId == accountTransaction.accountTransactionUserId
                                        && transactionProductId == productId
                                        && transactionUserId == userId
                                        && transactionDescription.like("%\(searchText.uppercased())%")
                                        && transactionDate >= startDate
        ).order(transactionDate.desc)
            .limit(limit)
        return table
    }
    
    func prepareUnreadAccountTransactionsQuery(userId: String, productId: String, startDate: Date, limit: Int?) -> Table {
        let table = transactionTable.join(accountTransaction.accountTransactionTable,
                                     on: transactionId == accountTransaction.accountTransactionId
                                        && transactionProductId == accountTransaction.accountTransactionProductId
                                        && transactionUserId == accountTransaction.accountTransactionUserId
                                        && transactionProductId == productId
                                        && transactionUserId == userId
                                        && transactionDate >= startDate
                                        && transactionRead == 0
        ).order(transactionDate.desc)
        .limit(limit)
        return table
    }
    
    func prepareUnreadCardTransactionsQuery(userId: String, productId: String, startDate: Date, limit: Int?) -> Table {
        let table = transactionTable.join(cardTransaction.cardTransactionTable,
                                     on: transactionId == cardTransaction.cardTransactionId
                                        && transactionProductId == cardTransaction.cardTransactionProductId
                                        && transactionUserId == cardTransaction.cardTransactionUserId
                                        && transactionProductId == productId
                                        && transactionUserId == userId
                                        && transactionDate >= startDate
                                        && transactionRead == 0
        ).order(transactionDate.desc)
            .limit(limit)
        return table
    }
    
    func prepareSearchCardTransactionsQuery(userId: String, productId: String, startDate: Date, searchText: String, limit: Int) -> Table {
        
        let table = transactionTable.join(cardTransaction.cardTransactionTable,
                                          on: transactionId == cardTransaction.cardTransactionId
                                            && transactionProductId == cardTransaction.cardTransactionProductId
                                            && transactionUserId == cardTransaction.cardTransactionUserId
                                            && transactionProductId == productId
                                            && transactionUserId == userId
                                            && transactionDescription.like("%\(searchText.uppercased())%")
                                            && transactionDate >= startDate
        ).order(transactionDate.desc)
            .limit(limit)
        return table
    }
    
    // # MARK: Private methods
    
    private func prepareRAWQuery(filters: [String], income: Bool = false) -> String {
        let comparator = income ? ">" : "<"
        return "SELECT SUM(\(DAOTransaction.transactionAmountField)) / ? AS \(DAOTransaction.transactionAverageField) " +
            "FROM \(DAOTransaction.tableName) t1 " +
            "WHERE \(DAOTransaction.transactionProductIdField) = ? AND " +
            "\(DAOProduct.productUserIdField) = ? AND " +
            "\(DAOTransaction.transactionAmountField) \(comparator) 0 AND " +
            "\(DAOTransaction.transactionDateField) BETWEEN ? AND ? AND " +
            "\(DAOTransaction.transactionCurrencyField) = ? AND " +
            "NOT EXISTS \(getInternalTransferFilterQuery())" +
            getDescriptionFilterQuery(filters: filters)
    }
    
    private func prepareRAWQueryForAccountMovementsWithFilters(includeInternalTransfers: Bool = true) -> String {
        let sqlQuery =
            "SELECT * " +
            "FROM \(DAOTransaction.tableName) t1 INNER JOIN \(DAOAccountTransaction.tableName) t2 " +
            "ON t1.\(DAOTransaction.transactionIdField) = t2.\(DAOAccountTransaction.accountTransactionIdField) AND " +
            "t1.\(DAOTransaction.transactionProductIdField) = t2.\(DAOAccountTransaction.accountTransactionProductIdField) AND " +
            "t1.\(DAOProduct.productUserIdField) = t2.\(DAOAccountTransaction.accountTransactionUserIdField) " +
            "WHERE t1.\(DAOTransaction.transactionProductIdField) = ? AND " +
            "t1.\(DAOProduct.productUserIdField) = ? AND " +
            "t1.\(DAOTransaction.transactionDateField) BETWEEN ? AND ? AND " +
            "t1.\(DAOTransaction.transactionCurrencyField) = ? "
        if includeInternalTransfers == true {
            return sqlQuery +  "AND " + "NOT EXISTS \(getInternalTransferFilterQuery())" + " ORDER BY t1.\(DAOTransaction.transactionDateField) DESC"
        } else {
            return sqlQuery + " ORDER BY t1.\(DAOTransaction.transactionDateField) DESC"
        }
    }
    
    private func getInternalTransferFilterQuery() -> String {
        let query = "SELECT 1 FROM \(DAOTransaction.tableName) t2 " +
            "WHERE t1.\(DAOTransaction.transactionDateField) = t2.\(DAOTransaction.transactionDateField) AND " +
            "t1.\(DAOTransaction.transactionAmountField) = -t2.\(DAOTransaction.transactionAmountField) AND " +
            "t1.\(DAOProduct.productUserIdField) = t2.\(DAOProduct.productUserIdField) AND " +
            "t1.\(DAOTransaction.transactionProductIdField) <> t2.\(DAOTransaction.transactionProductIdField) AND " +
            "t1.\(DAOTransaction.transactionDescriptionField) LIKE '%TRANSFERENCIA%' AND " +
        "t2.\(DAOTransaction.transactionDescriptionField) LIKE '%TRANSFERENCIA%'"
        return "(\(query))"
    }
    
    private func getDescriptionFilterQuery(filters: [String]) -> String {
        var queryFilter = ""
        filters.forEach { filter in
            queryFilter += " AND \(DAOTransaction.transactionDescriptionField) NOT LIKE '%\(filter)%'"
        }
        return queryFilter
    }
    
    private func transactionModel(row: Row) -> TransactionModel {
        return TransactionModel(
            transactionType: ConstantsPFM.accountTransaction,
            id: row[transactionId],
            productId: row[transactionProductId],
            userId: row[transactionUserId],
            date: row[transactionDate],
            amount: row[transactionAmount],
            currency: row[transactionCurrency],
            description: row[transactionDescription],
            read: row[transactionRead],
            bankCode: row[transactionBankCode],
            branchCode: row[transactionBranchCode],
            product: row[transactionProduct],
            contractnumber: row[transactionContractnumber],
            annotationDate: row[transactionAnnotationDate],
            valueDate: row[transactionValueDate],
            transactionDay: row[transactionDay],
            transactionNumber: row[transactionNumber])
    }
    
    private func transactionModel(rows: [Binding]) -> TransactionModel? {
        let rowValues = rows.compactMap({$0})
        guard
            rowValues.count == 27,
            let transactionID = rowValues[0] as? String,
            let productID = rowValues[1] as? String,
            let userID = rowValues[2] as? String,
            let trDate = (rowValues[3] as? String),
            let trAmount = rowValues[4] as? Int64,
            let trCurrency = rowValues[5] as? String,
            let trDescription = rowValues[6] as? String,
            let trRead = rowValues[7] as? Int64,
            let trbankCode = rowValues[8] as? String,
            let trBranchCode = rowValues[9] as? String,
            let trProduct = rowValues[10] as? String,
            let trContractNumber = rowValues[11] as? String,
            let trAnnotationDate = rowValues[12] as? String,
            let trValueDate = rowValues[13] as? String,
            let trTransactionDay = rowValues[14] as? String,
            let trTransactionNumber = rowValues[15] as? String,
            let trDateFormmated = trDate.toFormmatedFromUTC(),
            let trAnnotationDateFormmated = trAnnotationDate.toFormmatedFromUTC(),
            let trValueDateFormmated = trValueDate.toFormmatedFromUTC()
            else { return nil }
        return TransactionModel(
            transactionType: ConstantsPFM.accountTransaction,
            id: transactionID,
            productId: productID,
            userId: userID,
            date: trDateFormmated,
            amount: trAmount,
            currency: trCurrency,
            description: trDescription,
            read: Int(trRead),
            bankCode: trbankCode,
            branchCode: trBranchCode,
            product: trProduct,
            contractnumber: trContractNumber,
            annotationDate: trAnnotationDateFormmated,
            valueDate: trValueDateFormmated,
            transactionDay: trTransactionDay,
            transactionNumber: trTransactionNumber)
    }
}
// swiftlint:enable type_body_length
