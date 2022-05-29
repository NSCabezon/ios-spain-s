//

import Foundation
import Fuzi

public class ValidationSwiftParse : BSANParser<ValidationSwiftResponse, ValidationSwiftHandler> {
    override func setResponseData(){
        response.validationSwiftDTO  = handler.validationSwiftDTO
    }
}

public class ValidationSwiftHandler: BSANHandler {
    var validationSwiftDTO = ValidationSwiftDTO()
    
    override func parseResult(result: XMLElement) throws {
        validationSwiftDTO = ValidationSwiftParser.parse(result)
    }
    
}
