import Foundation
import Fuzi

public class GetPortfolioTransactionsParser : BSANParser <GetPortfolioTransactionsResponse, GetPortfolioTransactionsHandler> {
    override func setResponseData(){
        response.transactionList = handler.transactionList
        response.transactionList.pagination = handler.pagination
    }
}

public class GetPortfolioTransactionsHandler: BSANHandler {
    
    var transactionList = PortfolioTransactionsListDTO()
    var pagination : PaginationDTO?
    
    override func parseResult(result: XMLElement) throws {
        if let lista = result.firstChild(tag: "lista"){
            transactionList = PortfolioTransactionsListDTOParser.parse(lista)
        }
        
        pagination = PaginationParser.parse(result)
    }
}
