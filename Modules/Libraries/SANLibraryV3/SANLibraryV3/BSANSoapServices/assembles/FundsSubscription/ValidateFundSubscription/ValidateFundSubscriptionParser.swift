import Foundation
import Fuzi

public class ValidateFundSubscriptionParser : BSANParser <ValidateFundSubscriptionResponse, ValidateFundSubscriptionHandler> {
    override func setResponseData(){
        response.fundSuscriptionDTO = handler.fundSuscriptionDTO
    }
}

public class ValidateFundSubscriptionHandler: BSANHandler {
    
    var fundSuscriptionDTO = FundSubscriptionDTO()
    
    override func parseResult(result: XMLElement) throws {
        fundSuscriptionDTO = FundSubscriptionDTOParser.parse(result)
    }
}
