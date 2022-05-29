import Foundation
import Fuzi

class ValidateChangeMassiveDirectDebitsAccountParser: BSANParser<ValidateChangeMassiveDirectDebitsAccountResponse, ValidateChangeMassiveDirectDebitsAccountHandler> {
        
    override func setResponseData() {
        response.signature = handler.signature
    }
}

class ValidateChangeMassiveDirectDebitsAccountHandler: BSANHandler {
    
    fileprivate var signature: SignatureWithTokenDTO?
    
    override func parseResult(result: XMLElement) throws {
        signature = SignatureWithTokenDTOParser.parse(result)
    }
}


