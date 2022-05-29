import Foundation
import Fuzi

public class ModifyPeriodicTransferParser : BSANParser<ModifyPeriodicTransferResponse, ModifyPeriodicTransferHandler> {
    override func setResponseData(){
        response.modifyPeriodicTransferDTO  = handler.modifyPeriodicTransferDTO
    }
}

public class ModifyPeriodicTransferHandler: BSANHandler {
    var modifyPeriodicTransferDTO = ModifyPeriodicTransferDTO()
    
    override func parseResult(result: XMLElement) throws {
        modifyPeriodicTransferDTO = ModifyPeriodicTransferDTOParser.parse(result)
    }
    
}
