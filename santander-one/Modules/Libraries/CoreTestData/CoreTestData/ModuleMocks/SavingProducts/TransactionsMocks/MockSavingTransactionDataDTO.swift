import CoreDomain
import OpenCombine

struct MockSavingTransactionDataDTO: Codable {
    let transactionsDTO: [MockSavingTransactionDTO]
    let accountsDTO: [MockSavingAccountDTO]?
    
    enum CodingKeys: String, CodingKey {
        case transactionsDTO = "Transaction"
        case accountsDTO = "Account"
    }
}

extension MockSavingTransactionDataDTO: SavingTransactionDataRepresentable {
    var transactions: [SavingTransactionRepresentable] {
        return transactionsDTO
    }
    
    var accounts: [SavingAccountRepresentable]? {
        return accountsDTO
    }
}
