//

import Foundation
import Fuzi

public class ValidationNoSEPAParser : BSANParser<ValidationNoSEPAResponse, ValidationNoSEPAHandler> {
    override func setResponseData(){
        response.validationIntNoSEPA  = handler.validationIntNoSEPA
    }
}

public class ValidationNoSEPAHandler: BSANHandler {
    var validationIntNoSEPA = ValidationIntNoSepaDTO()
    
    override func parseResult(result: XMLElement) throws {
        validationIntNoSEPA = ValidationIntNoSepaParser.parse(result)
    }
    
}
