import Foundation
import Fuzi

public class DirectMoneyConfirmationParser : BSANParser <BSANSoapResponse, DirectMoneyConfirmationHandler> {
    override func setResponseData(){
    }
}

public class DirectMoneyConfirmationHandler: BSANHandler {
        
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
            
        default:
            BSANLogger.e("DirectMoneyConfirmationHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
