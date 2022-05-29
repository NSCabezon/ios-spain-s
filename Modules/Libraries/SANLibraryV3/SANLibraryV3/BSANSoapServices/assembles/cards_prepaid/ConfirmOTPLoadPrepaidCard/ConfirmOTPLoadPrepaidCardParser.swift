import Foundation
import Fuzi

public class ConfirmOTPLoadPrepaidCardParser : BSANParser <BSANSoapResponse, ConfirmOTPLoadPrepaidCardHandler> {
    override func setResponseData(){
    }
}

public class ConfirmOTPLoadPrepaidCardHandler: BSANHandler {
        
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        default:
            BSANLogger.e("ValidateOTPLoadPrepaidCardHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
