import Foundation
import Fuzi

public class ConfirmUsualTransferParser : BSANParser <ConfirmUsualTransferResponse, ConfirmUsualTransferHandler> {
    override func setResponseData(){
        response.transferConfirmAccountDTO = handler.transferConfirmAccountDTO
    }
}

public class ConfirmUsualTransferHandler: BSANHandler {
    var transferConfirmAccountDTO = TransferConfirmAccountDTO()
    
    override func parseResult(result: XMLElement) throws {
        transferConfirmAccountDTO = TransferConfirmAccountDTOParser.parse(result)
    }
}
