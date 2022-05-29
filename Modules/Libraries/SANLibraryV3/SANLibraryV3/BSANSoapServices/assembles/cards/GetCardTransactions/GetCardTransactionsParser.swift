import Foundation
import Fuzi

public class GetCardTransactionsParser : BSANParser <GetCardTransactionsResponse, GetCardTransactionsHandler> {
    override func setResponseData(){
        response.transactionList = handler.transactionList
        response.transactionList.pagination = handler.pagination
    }
}

public class GetCardTransactionsHandler: BSANHandler {
    
    var transactionList = CardTransactionsListDTO()
    var pagination = PaginationDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let lista = result.firstChild(tag: "lista"){
            for dato in lista.children(tag: "dato") {
                let cardTransactionDTO = CardTransactionDTOParser.parse(dato)
                transactionList.transactionDTOs.append(cardTransactionDTO)
            }
        }
        pagination = PaginationParser.parse(result)
    }
}
