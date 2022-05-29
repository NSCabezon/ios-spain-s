import Foundation
import Fuzi

public class ConfirmCesOTPParser : BSANParser <BSANSoapResponse, ConfirmCesOTPHandler> {
    override func setResponseData() {
    }
}

public class ConfirmCesOTPHandler: BSANHandler {
    override func parseResult(result: XMLElement) throws {
    }
}

