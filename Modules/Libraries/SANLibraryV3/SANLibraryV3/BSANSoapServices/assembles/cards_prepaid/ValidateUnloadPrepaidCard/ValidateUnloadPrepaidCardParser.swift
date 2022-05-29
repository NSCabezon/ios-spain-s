import Foundation
import Fuzi

public class ValidateUnloadPrepaidCardParser : BSANParser <ValidateUnloadPrepaidCardResponse, ValidateUnloadPrepaidCardHandler> {
    override func setResponseData(){
        response.validateLoadPrepaidCardDTO = handler.validateLoadPrepaidCardDTO
    }
}

public class ValidateUnloadPrepaidCardHandler: BSANHandler {
    
    var validateLoadPrepaidCardDTO = ValidateLoadPrepaidCardDTO()
    
    override func parseResult(result: XMLElement) throws {
        validateLoadPrepaidCardDTO = ValidateLoadPrepaidCardDTOParser.parse(result)
    }
}
