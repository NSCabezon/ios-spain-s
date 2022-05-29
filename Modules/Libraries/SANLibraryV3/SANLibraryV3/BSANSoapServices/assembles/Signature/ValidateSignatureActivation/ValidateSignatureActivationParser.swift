import Foundation
import Fuzi

public class ValidateSignatureActivationParser : BSANParser <ValidateSignatureActivationResponse, ValidateSignatureActivationHandler> {
    override func setResponseData(){
        response.signatureWithTokenDTO = handler.signatureWithTokenDTO
    }
}

public class ValidateSignatureActivationHandler: BSANHandler {
    
    var signatureWithTokenDTO = SignatureWithTokenDTO()
    
    override func parseResult(result: XMLElement) throws {
        self.signatureWithTokenDTO = SignatureWithTokenDTOParser.parse(result)
    }
}
