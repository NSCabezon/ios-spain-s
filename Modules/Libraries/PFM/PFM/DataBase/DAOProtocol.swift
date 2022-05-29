import Foundation
import SQLite

struct ConstantsPFM {
    static let accountType = "ACCOUNT"
    static let cardType = "CARD"
    static let accountTransaction = "ACCOUNT_TRANSACTION"
    static let cardTransaction = "CARD_TRANSACTION"
}

protocol DAOProtocol {
    static var tableName: String { get }

    func createTable() -> String
    
    init(dbm: DataBaseManager)
}
