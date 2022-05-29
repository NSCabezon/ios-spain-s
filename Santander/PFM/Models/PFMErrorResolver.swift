import Foundation
import PFM
import Login
import CoreFoundationLib

class PFMErrorResolver: PFMErrorResolverProtocol {
    private let key19FebError = "PFMErrorResolver.key19FebError"
    
    func resolve() {
        if UserDefaults.standard.bool(forKey: key19FebError) != true {
            if existsDB() {
                migrateBadMovements()
            }
            UserDefaults.standard.set(true, forKey: key19FebError)
        }
    }
    
    private func migrateBadMovements() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        guard let startDate = formatter.date(from: "2018/10/01") else {
            return
        }
        let endDate = Date()
        let type = Constants.cardType
        let manager = DataBaseManager.shared
        let products = manager.product.products(type: type)
        for item in products ?? [] {
            let userId = item.userId
            let productId = item.id
            let result = manager.transaction.lastCardTransactionsSearch(userId: userId, productId: productId, startDate: startDate, endDate: endDate)
            result.forEach {
                let cardTransaction = $0
                let transaction = cardTransaction.transaction
                let cardTransactionPfm = CardTransactionPfm(transactionModel: transaction, cardTransactionModel: cardTransaction)
                let pk = cardTransactionPfm.pk
                let transactionId = transaction.id
                if pk != transactionId {
                    manager.transaction.deleteTransaction(transactionId: transactionId, userId: userId)
                    manager.transaction.deleteCardTransaction(transactionId: transactionId, userId: userId)
                    let transactionModel = TransactionModel(model: transaction, id: pk)
                    let cardTransactionModel = CardTransactionModel(transaction: transactionModel, balanceCode: cardTransaction.balanceCode)
                    manager.transaction.insertTransaction(transaction: transactionModel)
                    manager.transaction.insertCardTransaction(cardTransaction: cardTransactionModel)
                }
            }
        }
    }
    
    private func existsDB() -> Bool {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("san2.sqlite3")
        let fileManager = FileManager.default
        return  fileManager.fileExists(atPath: fileURL.path) && fileManager.fileExists(atPath: fileURL.path)
    }
}
