import Foundation
import Fuzi

public class ModifyDeferredTransferParser : BSANParser<ModifyDeferredTransferResponse, ModifyDeferredTransferHandler> {
    override func setResponseData(){
        response.modifyDeferredTransferDTO  = handler.modifyDeferredTransferDTO
    }
}

public class ModifyDeferredTransferHandler: BSANHandler {
    var modifyDeferredTransferDTO = ModifyDeferredTransferDTO()
    
    override func parseResult(result: XMLElement) throws {
        modifyDeferredTransferDTO = ModifyDeferredTransferDTOParser.parse(result)
    }
    
}
