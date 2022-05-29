import Foundation
import Fuzi

public class ConfirmOTPUnloadPrepaidCardParser : BSANParser <BSANSoapResponse, ConfirmOTPUnloadPrepaidCardHandler> {
    override func setResponseData(){
    }
}

public class ConfirmOTPUnloadPrepaidCardHandler: BSANHandler {
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        default:
            BSANLogger.e("ValidateOTPUnloadPrepaidCardHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
