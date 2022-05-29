import Fuzi

public class ConsultSignatureBillTaxesParser: BSANParser<ConsultSignatureBillTaxesResponse, ConsultSignatureBillTaxesHandler> {
    override func setResponseData() {
        response.signatureWithTokenDTO = handler.signatureWithTokenDTO
    }
}

public class ConsultSignatureBillTaxesHandler: BSANHandler {
    
    var signatureWithTokenDTO = SignatureWithTokenDTO()
    
    override func parseResult(result: XMLElement) throws {
        self.signatureWithTokenDTO = SignatureWithTokenDTOParser.parse(result)
    }
}
