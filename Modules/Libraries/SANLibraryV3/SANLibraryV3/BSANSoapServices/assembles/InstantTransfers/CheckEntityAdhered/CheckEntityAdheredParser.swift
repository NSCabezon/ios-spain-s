import Foundation
import Fuzi

public class CheckEntityAdheredParser : BSANParser <BSANSoapResponse, CheckEntityAdheredHandler> {
    override func setResponseData(){
    }
}

public class CheckEntityAdheredHandler: BSANHandler {
    
    override func parseResult(result: XMLElement) throws {
    }
}

