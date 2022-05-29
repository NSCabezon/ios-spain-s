import Foundation

public struct FundInfo: Codable {
    public var fundWithDetailDictionary: [String : FundDetailDTO] = [:]
    public var fundTransactionsDictionary: [String : FundTransactionsListDTO] = [:]
    public var fundTransactionWithDetailDictionary: [String : FundTransactionDetailDTO] = [:]

    public mutating func addFundTransactions(fundTransactionsListDTO: FundTransactionsListDTO, contract: String) {
        var newStoredTransactions = [FundTransactionDTO]()
        if let storedTransactions = fundTransactionsDictionary[contract] {
            newStoredTransactions = storedTransactions.transactionDTOs
        }
        newStoredTransactions += fundTransactionsListDTO.transactionDTOs
        fundTransactionsDictionary[contract] = FundTransactionsListDTO(transactionDTOs: newStoredTransactions, pagination: fundTransactionsListDTO.pagination)
    }
}
