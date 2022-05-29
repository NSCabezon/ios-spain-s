import Foundation
import Fuzi

public class BSANSoapEmptyParser : BSANParser <BSANSoapEmptyResponse, BSANSoapEmptyParser.Handler> {
    override func setResponseData(){
    }
    
    public class Handler: BSANHandler {
        
        override func parseElement(element: XMLElement) throws {
        }
        override func parseResult(result: XMLElement) throws {
        }
    }
}
