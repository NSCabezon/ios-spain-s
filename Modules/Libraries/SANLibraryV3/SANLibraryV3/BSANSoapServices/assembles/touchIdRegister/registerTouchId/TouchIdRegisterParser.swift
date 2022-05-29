import Fuzi

public class TouchIdRegisterParser: BSANParser<TouchIdRegisterResponse, TouchIdRegisterHandler> {
    override func setResponseData() {
        response.touchIdRegisterDTO = handler.touchIdRegisterDTO
    }
}

public class TouchIdRegisterHandler: BSANHandler {
    var touchIdRegisterDTO = TouchIdRegisterDTO()
    
    override func parseResult(result: XMLElement) throws {
        touchIdRegisterDTO = TouchIdRegisterDTOParser.parse(result)
    }
}
