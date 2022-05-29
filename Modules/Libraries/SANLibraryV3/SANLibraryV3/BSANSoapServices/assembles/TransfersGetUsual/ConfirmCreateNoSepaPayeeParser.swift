import Foundation
import Fuzi

public class ConfirmCreateNoSepaPayeeParser: BSANParser<ConfirmCreateNoSepaPayeeResponse, ConfirmCreateNoSepaPayeeHandler> {
        
    override func setResponseData() {
        response.confirmCreateNoSepaPayeeDTO = handler.confirmCreateNoSepaPayeeDTO
    }
}

public class ConfirmCreateNoSepaPayeeHandler: BSANHandler {
    var confirmCreateNoSepaPayeeDTO = ConfirmCreateNoSepaPayeeDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let payeeCode = result.firstChild(tag: "codigoPayee") {
            confirmCreateNoSepaPayeeDTO.codPayee = payeeCode.stringValue.trim()
        }
    }
}


