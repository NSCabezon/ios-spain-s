import Foundation
import Fuzi

public class ValidateRemoveSepaPayeeParser: BSANParser<ValidateRemoveSepaPayeeResponse, ValidateRemoveSepaPayeeHandler> {
    
    override func setResponseData() {
        response.signatureWithToken = handler.signature
    }
}

public class ValidateRemoveSepaPayeeHandler: BSANHandler {
    fileprivate var signature: SignatureWithTokenDTO?
    
    override func parseResult(result: XMLElement) throws {
        signature = SignatureWithTokenDTOParser.parse(result)
    }
}
