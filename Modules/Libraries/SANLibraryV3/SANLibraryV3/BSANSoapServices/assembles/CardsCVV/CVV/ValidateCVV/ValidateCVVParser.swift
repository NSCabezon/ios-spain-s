import Foundation
import Fuzi

public class ValidateCVVParser : BSANParser <ValidateCVVResponse, ValidateCVVHandler> {
    override func setResponseData(){
        response.signatureWithTokenDTO = handler.signatureWithTokenDTO
    }
}

public class ValidateCVVHandler: BSANHandler {
    
    var signatureWithTokenDTO = SignatureWithTokenDTO()
    
    override func parseResult(result: XMLElement) throws {
        self.signatureWithTokenDTO = SignatureWithTokenDTOParser.parse(result)
    }
}
