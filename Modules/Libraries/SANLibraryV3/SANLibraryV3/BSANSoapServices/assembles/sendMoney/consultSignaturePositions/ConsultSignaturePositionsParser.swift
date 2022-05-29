import Fuzi
public class ConsultSignaturePositionsParser : BSANParser<ConsultSignaturePositionsResponse, ConsultSignaturePositionsHandler> {
    override func setResponseData(){
        response.signatureWithTokenDTO = handler.signatureWithTokenDTO
    }
}

public class ConsultSignaturePositionsHandler: BSANHandler {
    
    var signatureWithTokenDTO = SignatureWithTokenDTO()
    
    override func parseResult(result: XMLElement) throws {
        self.signatureWithTokenDTO = SignatureWithTokenDTOParser.parse(result)
    }
}
