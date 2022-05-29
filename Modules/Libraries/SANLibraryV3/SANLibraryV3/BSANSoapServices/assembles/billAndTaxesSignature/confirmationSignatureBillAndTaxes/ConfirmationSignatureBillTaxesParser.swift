import Fuzi

public class ConfirmationSignatureBillTaxesParser: BSANParser<ConfirmationSignatureBillTaxesResponse, ConfirmationSignatureBillTaxesHandler> {
    override func setResponseData() {
        response.tokenCredential = handler.tokenCredential
    }
}

public class ConfirmationSignatureBillTaxesHandler: BSANHandler {
    var tokenCredential = BillAndTaxesTokenDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "dataToken":
            tokenCredential.token = element.stringValue.trim()
        default:
            BSANLogger.e("ConfirmationSignatureBillTaxesHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
