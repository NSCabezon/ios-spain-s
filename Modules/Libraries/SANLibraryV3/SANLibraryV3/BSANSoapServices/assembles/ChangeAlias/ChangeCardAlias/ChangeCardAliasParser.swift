import Foundation
import Fuzi

public class ChangeCardAliasParser : BSANParser <BSANSoapResponse, ChangeCardAliasHandler> {
    override func setResponseData(){
    }
}

public class ChangeCardAliasHandler: BSANHandler {
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        default:
            BSANLogger.e("ChangeCardAliasHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
