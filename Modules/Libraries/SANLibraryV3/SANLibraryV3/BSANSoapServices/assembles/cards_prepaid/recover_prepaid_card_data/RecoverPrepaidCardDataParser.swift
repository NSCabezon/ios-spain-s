import Foundation
import Fuzi

public class RecoverPrepaidCardDataParser : BSANParser<RecoverPrepaidCardDataResponse, RecoverPrepaidCardDataHandler> {
    override func setResponseData(){
        response.prepaidCardDTO = handler.prepaidCardDTO
    }
}

public class RecoverPrepaidCardDataHandler: BSANHandler {
    
    var prepaidCardDTO: PrepaidCardDataDTO = PrepaidCardDataDTO()
    
    override func parseResult(result: XMLElement) throws {
        prepaidCardDTO = PrepaidCardDataDTOParser.parse(result)
    }
}
