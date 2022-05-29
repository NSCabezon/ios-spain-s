import Foundation
import Fuzi

public class PensionTransactionsParser : BSANParser <PensionTransactionsResponse, PensionTransactionsHandler> {
    override func setResponseData(){
		response.pensionTransactions = PensionTransactionsListDTO(transactionDTOs: handler.pensionTransactions, pagination: handler.pagination)
    }
}

public class PensionTransactionsHandler: BSANHandler {
    
    var pensionTransactions = [PensionTransactionDTO]()
	var pagination = PaginationDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let lista = result.firstChild(tag: "lista"){
            pensionTransactions = PensionTransactionsDTOParser.parse(lista)
        }
        
        pagination = PaginationParser.parse(result)
    }
}

