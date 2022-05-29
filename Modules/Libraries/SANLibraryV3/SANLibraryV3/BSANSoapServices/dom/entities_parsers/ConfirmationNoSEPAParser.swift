import Fuzi

public class ConfirmationNoSEPAParser: BSANParser<ConfirmationNoSEPAResponse, ConfirmationNoSEPAHandler> {
    override func setResponseData(){
        response.confirmationNoSepa = handler.confirmationNoSepa
    }
}

public class ConfirmationNoSEPAHandler: BSANHandler {
    var confirmationNoSepa = ConfirmationNoSEPADTO()
    
    override func parseResult(result: XMLElement) throws {
        confirmationNoSepa.result = result.firstChild(tag: "retorno")?.stringValue
    }
}
