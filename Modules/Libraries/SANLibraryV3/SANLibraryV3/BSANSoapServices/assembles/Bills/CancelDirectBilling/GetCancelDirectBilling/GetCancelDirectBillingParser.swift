import Foundation
import Fuzi

public class GetCancelDirectBillingParser: BSANParser<GetCancelDirectBillingResponse, GetCancelDirectBillingHandler> {
        
    override func setResponseData() {
        response.getCancelDirectBillingDTO = handler.getCancelDirectBillingDTO
    }
}

public class GetCancelDirectBillingHandler: BSANHandler {
    
    fileprivate var getCancelDirectBillingDTO: GetCancelDirectBillingDTO?
    
    override func parseResult(result: XMLElement) throws {
        guard
            let tipauto = result.firstChild(tag: "TIPAUTO")?.stringValue.trim(),
            let cdinaut = result.firstChild(tag: "CDINAUT")?.stringValue.trim(),
            let signatureElement = result.firstChild(tag: "posicionesFirma")
        else {
            return
        }
        getCancelDirectBillingDTO = GetCancelDirectBillingDTO(tipauto: tipauto, cdinaut: cdinaut, signature: SignatureDTOParser.parse(signatureElement))
    }
}


