import Foundation
import SQLite
import Logger

class DAOCardTransaction: DAOProtocol {
    static var tableName = "table_transaction_card_data"
    static let cardTransactionIdField = "transaction_card_id"
    static let cardTransactionUserIdField = "transaction_card_data_user_id"
    static let cardTransactionProductIdField = "transaction_card_data_product_id"
    static let cardTransactionBalanceCodeField = "transaction_card_data_balance_code"
    
    private let dbm: DataBaseManager

    var cardTransactionTable: Table
    var cardTransactionId: Expression<String>
    var cardTransactionProductId: Expression<String>
    var cardTransactionUserId: Expression<String>
    var cardTransactionBalanceCode: Expression<String>

    private var transactionTable: Table
    private var transactionProductId: Expression<String>
    private var transactionUserId: Expression<String>
    private var transactionId: Expression<String>
    
    required init(dbm: DataBaseManager) {
        self.dbm = dbm

        cardTransactionTable = Table(DAOCardTransaction.tableName)
        cardTransactionId = Expression<String>(DAOCardTransaction.cardTransactionIdField)
        cardTransactionUserId = Expression<String>(DAOCardTransaction.cardTransactionUserIdField)
        cardTransactionProductId = Expression<String>(DAOCardTransaction.cardTransactionProductIdField)
        cardTransactionBalanceCode = Expression<String>(DAOCardTransaction.cardTransactionBalanceCodeField)
        
        transactionTable = Table(DAOTransaction.tableName)
        transactionProductId = Expression<String>(DAOTransaction.transactionProductIdField)
        transactionUserId = Expression<String>(DAOProduct.productUserIdField)
        transactionId = Expression<String>(DAOTransaction.transactionIdField)
    }
    
    func createTable() -> String {
        return cardTransactionTable.create(ifNotExists: true) { t in
            t.column(cardTransactionId)
            t.column(cardTransactionUserId)
            t.column(cardTransactionProductId)
            t.column(cardTransactionBalanceCode)
            t.primaryKey(cardTransactionId, cardTransactionProductId, cardTransactionUserId)
            t.foreignKey(cardTransactionId, references: transactionTable, transactionId, delete: .cascade)
            t.foreignKey(cardTransactionProductId, references: transactionTable, transactionProductId, delete: .cascade)
            t.foreignKey(cardTransactionUserId, references: transactionTable, transactionUserId, delete: .cascade)
        }
    }
    
    func insertCardTransaction(cardTransaction: CardTransactionModel) {
        dbm.run(insertCardTransactionQuery(cardTransaction: cardTransaction))
    }

    func insertCardTransaction(cardTransactions: [CardTransactionModel]) {
        for cardTransaction in cardTransactions {
            dbm.run(insertCardTransactionQuery(cardTransaction: cardTransaction))
        }
    }
    
    func cardTransaction(row: Row, transaction: TransactionModel) -> CardTransactionModel {
        let result = CardTransactionModel(transaction: transaction,
                                          balanceCode: row[cardTransactionBalanceCode])
        return result
    }
    
    func deleteTransaction(transactionId: String, userId: String) {
        let transactionToUpdate = selectTransactionQuery(id: transactionId, userId: userId)
        dbm.run(transactionToUpdate.delete())
    }

    // MARK: - Private
    
    private func selectTransactionQuery(id: String, userId: String) -> QueryType {
        return cardTransactionTable.filter(transactionId == id && transactionUserId == userId)
    }
    
    private func insertCardTransactionQuery(cardTransaction: CardTransactionModel) -> Insert {
        return cardTransactionTable.insert(or: OnConflict.ignore,
            cardTransactionId <- cardTransaction.transaction.id,
            cardTransactionUserId <- cardTransaction.transaction.userId,
            cardTransactionProductId <- cardTransaction.transaction.productId,
            cardTransactionBalanceCode <- cardTransaction.balanceCode )
    }

    private func selectCardTransactionQueryy(id: String, userId: String, productId: String) -> QueryType {
        return cardTransactionTable.filter(cardTransactionId == id && cardTransactionUserId == userId && cardTransactionProductId == productId)
    }
}
