import Foundation
import Fuzi

public class ValidateUpdateSepaPayeeParser: BSANParser<ValidateUpdateSepaPayeeResponse, ValidateUpdateSepaPayeeHandler> {
        
    override func setResponseData() {
        response.signatureWithToken = handler.signature
    }
}

public class ValidateUpdateSepaPayeeHandler: BSANHandler {
    fileprivate var signature: SignatureWithTokenDTO?
    
    override func parseResult(result: XMLElement) throws {
        signature = SignatureWithTokenDTOParser.parse(result)
    }
}
