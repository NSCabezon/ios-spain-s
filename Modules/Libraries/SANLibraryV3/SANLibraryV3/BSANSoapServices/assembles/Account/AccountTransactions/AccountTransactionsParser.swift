import Foundation
import Fuzi

public class AccountTransactionsParser : BSANParser <AccountTransactionsResponse, AccountTransactionsHandler> {
    override func setResponseData(){
		response.accountTransactions = AccountTransactionsListDTO(transactionDTOs: handler.accountTransactions, pagination: handler.pagination)
    }
}

public class AccountTransactionsHandler: BSANHandler {
    
    var accountTransactions = [AccountTransactionDTO]()
	var pagination = PaginationDTO()
    
    override func parseResult(result: XMLElement) throws {
        var newContract: ContractDTO? {
            return result.firstChild(tag: "contratoNuevo").map(ContractDTOParser.parse)
        }
        var productSubtypeCode : String? {
            return result.firstChild(tag: "codProducto").map({ $0.stringValue.trim() })
        }
        if let listadoMovimientos = result.firstChild(tag: "listadoMovimientos"){
            accountTransactions = AccountTransactionsDTOParser.parse(listadoMovimientos, newContract: newContract, productSubtypeCode: productSubtypeCode)
        }
        
        pagination = PaginationParser.parse(result)
    }
}

