import Foundation
import Fuzi

public class ValidatePinParser : BSANParser <ValidatePinResponse, ValidatePinHandler> {
    override func setResponseData(){
        response.signatureWithTokenDTO = handler.signatureWithTokenDTO
    }
}

public class ValidatePinHandler: BSANHandler {
    
    var signatureWithTokenDTO = SignatureWithTokenDTO()
    
    override func parseResult(result: XMLElement) throws {
        self.signatureWithTokenDTO = SignatureWithTokenDTOParser.parse(result)
    }
}
