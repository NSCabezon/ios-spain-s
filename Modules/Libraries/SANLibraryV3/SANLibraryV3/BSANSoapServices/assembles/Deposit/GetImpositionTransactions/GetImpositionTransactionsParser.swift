import Foundation
import Fuzi

public class GetImpositionTransactionsParser : BSANParser <GetImpositionTransactionsResponse, GetImpositionTransactionsHandler> {
    override func setResponseData(){
        response.impositionTransactionsListDTO = handler.impositionTransactionsDTO
    }
}

public class GetImpositionTransactionsHandler: BSANHandler {
    
    var impositionTransactionsDTO = ImpositionTransactionsListDTO()

    override func parseResult(result: XMLElement) throws {

        if let lista = result.firstChild(tag: "lista"){
            impositionTransactionsDTO = ImpositionTransactionsListDTOParser.parse(lista, pagination: PaginationParser.parse(result))
        }
    }
}
