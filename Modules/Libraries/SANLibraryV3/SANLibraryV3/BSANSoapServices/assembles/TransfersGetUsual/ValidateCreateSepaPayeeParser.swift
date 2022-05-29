import Foundation
import Fuzi

public class ValidateCreateSepaPayeeParser: BSANParser<ValidateCreateSepaPayeeResponse, ValidateCreateSepaPayeeHandler> {
    
    override func setResponseData() {
        response.signatureWithToken = handler.signature
    }
}

public class ValidateCreateSepaPayeeHandler: BSANHandler {
    fileprivate var signature: SignatureWithTokenDTO?
    
    override func parseResult(result: XMLElement) throws {
        signature = SignatureWithTokenDTOParser.parse(result)
    }
}
