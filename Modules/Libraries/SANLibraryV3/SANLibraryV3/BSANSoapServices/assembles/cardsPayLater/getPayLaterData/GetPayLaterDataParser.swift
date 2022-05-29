import Fuzi

public class GetPayLaterDataParser: BSANParser<GetPayLaterDataResponse, GetPayLaterDataHandler> {
    override func setResponseData() {
        response.payLaterDTO = handler.payLaterDTO
    }
}

public class GetPayLaterDataHandler: BSANHandler {
    var payLaterDTO = PayLaterDTO()
    
    override func parseResult(result: XMLElement) throws {
        payLaterDTO = PayLaterDTOParser.parse(result)
    }
}
