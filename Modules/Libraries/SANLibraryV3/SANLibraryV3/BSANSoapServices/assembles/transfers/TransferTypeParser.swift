//

import Foundation
import Fuzi

public class TransferTypeParser : BSANParser<TransferTypeResponse, TransferTypeHandler> {
    override func setResponseData(){
        response.transferType  = handler.transferType
    }
}

public class TransferTypeHandler: BSANHandler {
    var transferType = TransfersType("")
    
    override func parseResult(result: XMLElement) throws {
        if let tipoSepa = result.firstChild(tag: "tipoSEPA"){
            transferType = TransfersType(tipoSepa.stringValue.trim())
        }
    }
    
}
