import Foundation
import Fuzi

public class ValidateCreateNoSepaPayeeParser: BSANParser<ValidateCreateNoSepaPayeeResponse, ValidateCreateNoSepaPayeeHandler> {
    
    override func setResponseData() {
        response.signatureWithToken = handler.signature
    }
}

public class ValidateCreateNoSepaPayeeHandler: BSANHandler {
    fileprivate var signature: SignatureWithTokenDTO?
    
    override func parseResult(result: XMLElement) throws {
        signature = SignatureWithTokenDTOParser.parse(result)
    }
}


