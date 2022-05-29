import Foundation
import Fuzi

public class CheckTransferStatusParser : BSANParser <CheckTransferStatusResponse, CheckTransferStatusHandler> {
    override func setResponseData(){
        response.checkTransferStatusDTO = handler.checkTransferStatusDTO
    }
}

public class CheckTransferStatusHandler: BSANHandler {
    
    var checkTransferStatusDTO = CheckTransferStatusDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let codInfo = result.firstChild(tag: "codInfo") {
            checkTransferStatusDTO.codInfo = codInfo.stringValue.trim()
        }
        
        if let estadoPago = result.firstChild(tag: "estadoPago") {
            checkTransferStatusDTO.statePayment = estadoPago.stringValue.trim()
        }
    }
}
