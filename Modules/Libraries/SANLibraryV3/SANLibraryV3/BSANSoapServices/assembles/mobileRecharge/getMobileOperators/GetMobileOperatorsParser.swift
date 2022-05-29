import Fuzi

public class GetMobileOperatorsParser: BSANParser<GetMobileOperatorsResponse, GetMobileOperatorsHandler> {
    override func setResponseData() {
        response.mobileOperatorListDTO = handler.mobileOperatorList
    }
}

public class GetMobileOperatorsHandler: BSANHandler {
    
    var mobileOperatorList = MobileOperatorListDTO()
    
    override func parseResult(result: XMLElement) throws {
        mobileOperatorList = MobileOperatorListDTOParser.parse(result)
    }
}
