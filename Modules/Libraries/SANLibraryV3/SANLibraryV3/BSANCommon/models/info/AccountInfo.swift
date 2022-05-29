import Foundation

public struct AccountInfo: Codable {
    public var accountTransactionsDictionary: [String : AccountTransactionsListDTO] = [:]
    public var accountDetailDictionary: [String : AccountDetailDTO] = [:]
    public var accountTransactionDetailDictionary: [String : AccountTransactionDetailDTO] = [:]
    public var personDataMap: [String: PersonDataDTO] = [:]

    public mutating func addAccountTransactions(accountTransactionsListDTO: AccountTransactionsListDTO, contract: String) {
        var newStoredTransactions = [AccountTransactionDTO]()
        if let storedTransactions = accountTransactionsDictionary[contract] {
            newStoredTransactions = storedTransactions.transactionDTOs
        }
        newStoredTransactions += accountTransactionsListDTO.transactionDTOs
        accountTransactionsDictionary[contract] = AccountTransactionsListDTO(transactionDTOs: newStoredTransactions, pagination: accountTransactionsListDTO.pagination)
    }
}
