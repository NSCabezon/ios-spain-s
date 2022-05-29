import Foundation
import Fuzi

public class ConfirmGenericTransferParser : BSANParser <ConfirmGenericTransferResponse, ConfirmGenericTransferHandler> {
    override func setResponseData(){
        response.transferConfirmAccountDTO = handler.transferConfirmAccountDTO
    }
}

public class ConfirmGenericTransferHandler: BSANHandler {
    var transferConfirmAccountDTO = TransferConfirmAccountDTO()
    
    override func parseResult(result: XMLElement) throws {
        transferConfirmAccountDTO = TransferConfirmAccountDTOParser.parse(result)
    }
}
