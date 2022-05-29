import Foundation

public struct LoanInfo: Codable {
    public var loanTransactionsDictionary: [String : LoanTransactionsListDTO] = [:]
    public var loanDetailDictionary: [String : LoanDetailDTO] = [:]
    public var loanTransactionDetailDictionary: [String : LoanTransactionDetailDTO] = [:]

    public mutating func addLoanTransactions(loanTransactionsListDTO: LoanTransactionsListDTO, contract: String) {
        var newStoredTransactions = [LoanTransactionDTO]()
        if let storedTransactions = loanTransactionsDictionary[contract] {
            newStoredTransactions = storedTransactions.transactionDTOs
        }
        newStoredTransactions += loanTransactionsListDTO.transactionDTOs
        loanTransactionsDictionary[contract] = LoanTransactionsListDTO(transactionDTOs: newStoredTransactions, pagination: loanTransactionsListDTO.pagination)
    }
    
    public mutating func removeLoanDetail(contractId: String) {
        loanDetailDictionary.removeValue(forKey: contractId)
    }
}


