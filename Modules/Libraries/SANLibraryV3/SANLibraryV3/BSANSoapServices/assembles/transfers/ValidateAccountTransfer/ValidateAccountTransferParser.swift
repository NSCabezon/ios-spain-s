import Foundation
import Fuzi

public class ValidateAccountTransferParser : BSANParser <ValidateAccountTransferResponse, ValidateAccountTransferHandler> {
    override func setResponseData(){
        response.transferAccountDTO = handler.transferAccountDTO
    }
}

public class ValidateAccountTransferHandler: BSANHandler {
    
    var transferAccountDTO = TransferAccountDTO()
    
    override func parseResult(result: XMLElement) throws {
        transferAccountDTO = TransferAccountDTOParser.parse(result)
    }
}
