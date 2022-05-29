import Foundation
import Fuzi

class BillEmittersPaymentConfirmationParser: BSANParser<BillEmittersPaymentConfirmationResponse, BillEmittersPaymentConfirmationHandler> {
        
    override func setResponseData() {
        response.confirmation = handler.confirmationDTO
    }
}

class BillEmittersPaymentConfirmationHandler: BSANHandler {
    
    fileprivate var confirmationDTO: BillEmittersPaymentConfirmationDTO?
    
    override func parseResult(result: XMLElement) throws {
        guard let billNumber = result.firstChild(tag: "numeroRecibo")?.stringValue else { return }
        self.confirmationDTO = BillEmittersPaymentConfirmationDTO(billNumber: billNumber)
    }
}


