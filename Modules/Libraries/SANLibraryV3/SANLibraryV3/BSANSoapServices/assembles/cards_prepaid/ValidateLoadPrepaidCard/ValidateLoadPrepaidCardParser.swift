import Foundation
import Fuzi

public class ValidateLoadPrepaidCardParser : BSANParser <ValidateLoadPrepaidCardResponse, ValidateLoadPrepaidCardHandler> {
    override func setResponseData(){
        response.validateLoadPrepaidCardDTO = handler.validateLoadPrepaidCardDTO
    }
}

public class ValidateLoadPrepaidCardHandler: BSANHandler {
    
    var validateLoadPrepaidCardDTO = ValidateLoadPrepaidCardDTO()
    
    override func parseResult(result: XMLElement) throws {
        validateLoadPrepaidCardDTO = ValidateLoadPrepaidCardDTOParser.parse(result)
    }
}
