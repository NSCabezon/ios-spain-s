import Foundation
import Fuzi

public class ConfirmFundTransferParser : BSANParser <BSANSoapResponse, ConfirmFundTransferHandler> {
    override func setResponseData(){
    }
}

public class ConfirmFundTransferHandler: BSANHandler {
    
    override func parseResult(result: XMLElement) throws {
    }
}
