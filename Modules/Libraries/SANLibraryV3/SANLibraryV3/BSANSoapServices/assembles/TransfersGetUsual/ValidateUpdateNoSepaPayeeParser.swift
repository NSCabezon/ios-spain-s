import Foundation
import Fuzi

public class ValidateUpdateNoSepaPayeeParser: BSANParser<ValidateUpdateNoSepaPayeeResponse, ValidateUpdateNoSepaPayeeHandler> {
        
    override func setResponseData() {
        response.signatureWithToken = handler.signature
    }
}

public class ValidateUpdateNoSepaPayeeHandler: BSANHandler {
    
    fileprivate var signature: SignatureWithTokenDTO?
    
    override func parseResult(result: XMLElement) throws {
        signature = SignatureWithTokenDTOParser.parse(result)
    }
}


