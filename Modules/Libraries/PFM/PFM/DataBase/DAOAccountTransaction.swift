import Foundation
import SQLite
import Logger

class DAOAccountTransaction: DAOProtocol {
    static let tableName = "table_transaction_account"
    static let accountTransactionIdField = "transaction_account_id"
    static let accountTransactionProductIdField = "transaction_account_product_id"
    static let accountTransactionUserIdField = "transaction_account_product_user_id"
    static let accountTransactionTypeField = "transaction_account_data_product_type"
    static let accountTransactionProductSubtypeCodeField = "transaction_account_data_product_subtype_code"
    static let accountTransactionTerminalCodeField = "transaction_account_data_terminal_code"
    static let accountTransactionNumberField = "transaction_account_data_number"
    static let accountTransactionCenterField = "transaction_account_data_center"
    static let accountTransactionCompanyField = "transaction_account_data_company"
    static let accountTransactionBalanceField = "transaction_account_data_transaction_balance"
    
    private let dbm: DataBaseManager

    var accountTransactionTable: Table
    var accountTransactionId: Expression<String>
    var accountTransactionProductId: Expression<String>
    var accountTransactionUserId: Expression<String>
    private var accountTransactionType: Expression<String>
    private var accountTransactionProductSubtypeCode: Expression<String>
    private var accountTransactionTerminalCode: Expression<String>
    private var accountTransactionNumber: Expression<String>
    private var accountTransactionCenter: Expression<String>
    private var accountTransactionCompany: Expression<String>
    private var accountTransactionBalance: Expression<Int64>
    
    private var transactionTable: Table
    private var transactionProductId: Expression<String>
    private var transactionUserId: Expression<String>
    private var transactionId: Expression<String>
    
    required init(dbm: DataBaseManager) {
        self.dbm = dbm

        accountTransactionTable = Table(DAOAccountTransaction.tableName)
        accountTransactionId = Expression<String>(DAOAccountTransaction.accountTransactionIdField)
        accountTransactionProductId = Expression<String>(DAOAccountTransaction.accountTransactionProductIdField)
        accountTransactionUserId = Expression<String>(DAOAccountTransaction.accountTransactionUserIdField)
        accountTransactionType = Expression<String>(DAOAccountTransaction.accountTransactionTypeField)
        accountTransactionProductSubtypeCode = Expression<String>(DAOAccountTransaction.accountTransactionProductSubtypeCodeField)
        accountTransactionTerminalCode = Expression<String>(DAOAccountTransaction.accountTransactionTerminalCodeField)
        accountTransactionNumber = Expression<String>(DAOAccountTransaction.accountTransactionNumberField)
        accountTransactionCenter = Expression<String>(DAOAccountTransaction.accountTransactionCenterField)
        accountTransactionCompany = Expression<String>(DAOAccountTransaction.accountTransactionCompanyField)
        accountTransactionBalance = Expression<Int64>(DAOAccountTransaction.accountTransactionBalanceField)
        
        transactionTable = Table(DAOTransaction.tableName)
        transactionProductId = Expression<String>(DAOTransaction.transactionProductIdField)
        transactionUserId = Expression<String>(DAOProduct.productUserIdField)
        transactionId = Expression<String>(DAOTransaction.transactionIdField)
        
    }
    
    func createTable() -> String {
        return accountTransactionTable.create(ifNotExists: true) { t in
            t.column(accountTransactionId)
            t.column(accountTransactionProductId)
            t.column(accountTransactionUserId)
            t.column(accountTransactionType)
            t.column(accountTransactionProductSubtypeCode)
            t.column(accountTransactionTerminalCode)
            t.column(accountTransactionNumber)
            t.column(accountTransactionCenter)
            t.column(accountTransactionCompany)
            t.column(accountTransactionBalance)
            t.primaryKey(accountTransactionId, accountTransactionProductId, accountTransactionUserId)
            t.foreignKey(accountTransactionId, references: transactionTable, transactionId, delete: .cascade)
            t.foreignKey(accountTransactionProductId, references: transactionTable, transactionProductId, delete: .cascade)
            t.foreignKey(accountTransactionUserId, references: transactionTable, transactionUserId, delete: .cascade)
        }
    }
    
    func insertAccountTransaction(accountTransaction: AccountTransactionModel) {
        dbm.run(insertAccountTransactionQuery(accountTransaction: accountTransaction))
    }
    
    func insertAccountTransaction(accountTransactions: [AccountTransactionModel]) {
        for accountTransaction in accountTransactions {
            dbm.run(insertAccountTransactionQuery(accountTransaction: accountTransaction))
        }
    }
    
    func accountTransaction(row: Row, transaction: TransactionModel) -> AccountTransactionModel? {
        let result = AccountTransactionModel(transaction: transaction,
                                        type: row[accountTransactionType],
                                        productSubtypeCode:  row[accountTransactionProductSubtypeCode],
                                        terminalCode: row[accountTransactionTerminalCode],
                                        number: row[accountTransactionNumber],
                                        center: row[accountTransactionCenter],
                                        company: row[accountTransactionCompany],
                                        balance: row[accountTransactionBalance])
        return result
    }
    
    func accountTransactionModel(rows: [Binding], transactionModel: TransactionModel) -> AccountTransactionModel? {
        let rowValues = rows.compactMap({$0})
        guard
            rowValues.count == 27,
            let type = rowValues[20] as? String,
            let productSubtypeCode = rowValues[21] as? String,
            let terminalCode = rowValues[22] as? String,
            let number = rowValues[23] as? String,
            let center = rowValues[24] as? String,
            let company = rowValues[25] as? String,
            let balance = rowValues[26] as? Int64
            else { return nil }
        return AccountTransactionModel(
            transaction: transactionModel,
            type: type,
            productSubtypeCode: productSubtypeCode,
            terminalCode: terminalCode,
            number: number,
            center: center,
            company: company,
            balance: balance)
    }
    
    // MARK: - Private
    
    private func insertAccountTransactionQuery(accountTransaction: AccountTransactionModel) -> Insert {
        return accountTransactionTable.insert(or: OnConflict.ignore,
            accountTransactionId <- accountTransaction.transaction.id,
            accountTransactionProductId <- accountTransaction.transaction.productId,
            accountTransactionUserId <- accountTransaction.transaction.userId,
            accountTransactionType <- accountTransaction.type,
            accountTransactionProductSubtypeCode <- accountTransaction.productSubtypeCode,
            accountTransactionTerminalCode <- accountTransaction.terminalCode,
            accountTransactionNumber <- accountTransaction.number,
            accountTransactionCenter <- accountTransaction.center,
            accountTransactionCompany <- accountTransaction.company,
            accountTransactionBalance <- accountTransaction.balance
        )
    }
    
    private func selectAccountTransactionQueryy(id: String, userId: String, productId: String) -> QueryType {
        return accountTransactionTable.filter(accountTransactionId == id && accountTransactionUserId == userId && accountTransactionProductId == productId)
    }
}
