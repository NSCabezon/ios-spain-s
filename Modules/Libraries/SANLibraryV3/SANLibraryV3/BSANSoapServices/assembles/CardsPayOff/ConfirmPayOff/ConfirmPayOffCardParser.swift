import Foundation
import Fuzi

public class ConfirmPayOffCardParser : BSANParser <BSANSoapResponse, ConfirmPayOffCardHandler> {
    override func setResponseData(){
    }
}

public class ConfirmPayOffCardHandler: BSANHandler {
    
    override func parseResult(result: XMLElement) throws {
    }
}
