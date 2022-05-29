import SANLibraryV3
import Foundation

struct AccountTransaction {
    let accountTransactionDTO: AccountTransactionDTO
    
    var balance: Amount {
        return Amount.createFromDTO(accountTransactionDTO.balance)
    }
    
    var amount: Amount {
        return Amount.createFromDTO(accountTransactionDTO.amount)
    }
    
    var operationDate: Date? {
        return accountTransactionDTO.operationDate
    }
    
    var description: String? {
        return accountTransactionDTO.description
    }
}
