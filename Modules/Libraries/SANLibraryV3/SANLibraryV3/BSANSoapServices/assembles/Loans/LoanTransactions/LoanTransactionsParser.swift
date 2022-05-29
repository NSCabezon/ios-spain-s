import Foundation
import Fuzi

public class LoanTransactionsParser : BSANParser <LoanTransactionsResponse, LoanTransactionsHandler> {
    override func setResponseData(){
		response.loanTransactions = LoanTransactionsListDTO(transactionDTOs: handler.loanTransactions, pagination: handler.pagination)
    }
}

public class LoanTransactionsHandler: BSANHandler {
    
    var loanTransactions = [LoanTransactionDTO]()
	var pagination = PaginationDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let lista = result.firstChild(tag: "lista"){
            loanTransactions = LoanTransactionsDTOParser.parse(lista)
        }
        
        pagination = PaginationParser.parse(result)
    }
}

