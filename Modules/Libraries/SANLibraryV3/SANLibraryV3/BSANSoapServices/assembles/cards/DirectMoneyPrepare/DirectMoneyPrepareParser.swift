import Foundation
import Fuzi

public class DirectMoneyPrepareParser : BSANParser <DirectMoneyPrepareResponse, DirectMoneyPrepareHandler> {
    override func setResponseData(){
        response.directMoneyDTO = handler.directMoneyDTO
    }
}

public class DirectMoneyPrepareHandler: BSANHandler {
    
    var directMoneyDTO = DirectMoneyDTO()
    
    override func parseResult(result: XMLElement) throws {
        directMoneyDTO = DirectMoneyDTOParser.parse(result)
    }
}
