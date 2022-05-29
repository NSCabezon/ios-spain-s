//

import Foundation
import Fuzi

public class OTPPushConfirmRegisterDeviceParser: BSANParser<OTPPushConfirmRegisterDeviceResponse, OTPPushConfirmRegisterDeviceHandler> {
    
    override func setResponseData(){
        response.confirmOTPPushDTO = handler.confirmOTPPushDTO
    }
}

public class OTPPushConfirmRegisterDeviceHandler: BSANHandler {
    
    fileprivate var confirmOTPPushDTO = ConfirmOTPPushDTO()
    
    override func parseResult(result: XMLElement) throws {
        guard let idDispositivo = result.firstChild(tag: "idDispositivo") else { return }
        confirmOTPPushDTO.deviceId = idDispositivo.stringValue.trim()
    }
}
