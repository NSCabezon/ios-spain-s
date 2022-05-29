import Foundation
import Fuzi

public class GetDuplicateBillParser: BSANParser<GetDuplicateBillResponse, GetDuplicateBillHandler> {
    override func setResponseData() {
        response.duplicateBillDTO = handler.duplicateBillDTO
    }
}

public class GetDuplicateBillHandler: BSANHandler {
    fileprivate var duplicateBillDTO: DuplicateBillDTO?
    
    override func parseResult(result: XMLElement) throws {
        guard let signatureElement = result.firstChild(tag: "posicionesFirma") else {
            return
        }
        let signature = SignatureDTOParser.parse(signatureElement)
        let concept = result.firstChild(tag: "concepto")?.stringValue
        let datePayment = DateFormats.safeDate(result.firstChild(tag: "fechaCargo")?.stringValue)
        let reference = result.firstChild(tag: "referenciaMandato")?.stringValue
        duplicateBillDTO = DuplicateBillDTO(signature: signature, concept: concept, datePayment: datePayment, reference: reference)
    }
}


