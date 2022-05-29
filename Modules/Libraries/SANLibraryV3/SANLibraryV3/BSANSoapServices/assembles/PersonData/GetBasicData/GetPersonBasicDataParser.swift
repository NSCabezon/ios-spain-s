import Fuzi

public class GetPersonBasicDataParser: BSANParser<GetPersonBasicDataResponse, GetPersonBasicDataHandler> {
    
    override func setResponseData() {
        response.personBasicDataDTO = handler.personBasicDataDTO
    }
}

public class GetPersonBasicDataHandler: BSANHandler {
    
    var personBasicDataDTO = PersonBasicDataDTO()
    
    override func parseResult(result: XMLElement) throws {
        let personBasicDataDTOParser = PersonBasicDataDTOParser()
        self.personBasicDataDTO = personBasicDataDTOParser.parse(result)
    }
}



