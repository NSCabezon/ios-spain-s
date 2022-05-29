
import Foundation
import Fuzi

public class DepositImpositionParser : BSANParser <DepositImpositionResponse, DepositImpositionHandler> {
    override func setResponseData(){
		response.impositionsDTOList = ImpositionsListDTO(impositionsDTOs: handler.impositionDTOs, pagination: handler.pagination)
    }
}

public class DepositImpositionHandler: BSANHandler {
    
    var impositionDTOs = [ImpositionDTO]()
	var pagination = PaginationDTO()
    
    override func parseResult(result: XMLElement) throws {
        impositionDTOs = ImpositionsDTOParser.parse(result)
        pagination = PaginationParser.parse(result)
    }
}

