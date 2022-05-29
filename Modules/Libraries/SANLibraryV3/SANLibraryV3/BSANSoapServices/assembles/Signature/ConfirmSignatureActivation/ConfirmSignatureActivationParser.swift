import Foundation
import Fuzi

public class ConfirmSignatureActivationParser : BSANParser <ConfirmSignatureActivationResponse, ConfirmSignatureActivationHandler> {
    override func setResponseData(){
        response.signatureWithTokenDTO = handler.signatureWithTokenDTO
    }
}

public class ConfirmSignatureActivationHandler: BSANHandler {
    
    var signatureWithTokenDTO: SignatureWithTokenDTO = SignatureWithTokenDTO()
    
    override func parseResult(result: XMLElement) throws {
        signatureWithTokenDTO = SignatureWithTokenDTOParser.parse(result)
    }
}
