import Foundation
import Fuzi

class OTPPushValidateDeviceParser: BSANParser<OTPPushValidateDeviceResponse, OTPPushValidateDeviceHandler> {
        
    override func setResponseData() {
        response.otpPushValidateDevice = handler.otpPushValidateDevice
    }
}

class OTPPushValidateDeviceHandler: BSANHandler {
    var otpPushValidateDevice = OTPPushValidateDeviceDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let returnCode = result.firstChild(tag: "codigoRetorno") {
            otpPushValidateDevice.returnCode = ReturnCodeOTPPush(Int(returnCode.stringValue.trim()) ?? 0)
        }
    }
}


