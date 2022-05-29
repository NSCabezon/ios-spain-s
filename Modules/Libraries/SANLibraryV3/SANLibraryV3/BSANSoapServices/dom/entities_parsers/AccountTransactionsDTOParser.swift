import Foundation
import Fuzi

class AccountTransactionsDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement, newContract: ContractDTO?, productSubtypeCode: String?) -> [AccountTransactionDTO] {
        var accountTransactions = [AccountTransactionDTO]()
        
        
        for element in node.children {
            var newAccountTransactionDTO = AccountTransactionDTOParser.parse(element)
            newAccountTransactionDTO.newContract = newContract
            newAccountTransactionDTO.productSubtypeCode = productSubtypeCode
            if newAccountTransactionDTO.operationDate != nil {
                accountTransactions.append(newAccountTransactionDTO)
            }
        }
        
        return accountTransactions
    }
}
