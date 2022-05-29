import Fuzi

public class ChangePaymentMethodParser : BSANParser<ChangePaymentMethodResponse, ChangePaymentMethodHandler> {
    override func setResponseData(){
        response.changePaymentDto = handler.changePaymentDto
    }
}

public class ChangePaymentMethodHandler: BSANHandler {
    
    var changePaymentDto: ChangePaymentDTO = ChangePaymentDTO()
    
    override func parseResult(result: XMLElement) throws {
        changePaymentDto = ChangePaymentDTOParser.parse(result)
    }
}
