import Foundation
import Fuzi

public class ConfirmPINParser : BSANParser <ConfirmPINResponse, ConfirmPINHandler> {
    override func setResponseData(){
        response.numPINCipher = handler.numPINCipher
    }
}

public class ConfirmPINHandler: BSANHandler {
    
    var numPINCipher = NumberCipherDTO()
    
    override func parseResult(result: XMLElement) throws {
        numPINCipher = NumberCipherDTOParser.parse(result)
    }
}
