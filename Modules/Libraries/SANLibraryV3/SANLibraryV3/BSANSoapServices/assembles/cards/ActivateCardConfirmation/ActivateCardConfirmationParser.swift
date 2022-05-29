import Foundation
import Fuzi

public class ActivateCardConfirmationParser : BSANParser <BSANSoapResponse, ActivateCardConfirmationHandler> {
    override func setResponseData(){
    }
}

public class ActivateCardConfirmationHandler: BSANHandler {
        
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {

        default:
            BSANLogger.e("ActivateCardConfirmationHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
