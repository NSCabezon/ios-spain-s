import Foundation

public class BSANParser<Response, Handler> where Response: BSANSoapResponse, Handler: BSANHandler {

    var handler: Handler!
    var response: Response!

    required public init(){}
    let WORKAROUND_OK = "Transaccion ok"
    
    func parse(bsanResponse: Response) throws -> Response {
        self.response = bsanResponse
        self.handler = instanceHandler()
        if !response!.isEmpty() {
            try handler.parse(data: bsanResponse.response!)
            if !checkError(bsanSoapResponse: bsanResponse, handler: handler) {
                self.setResponseData()
            }
        }
        return bsanResponse
    }


    func checkError(bsanSoapResponse: BSANSoapResponse, handler: BSANHandler) -> Bool {

        bsanSoapResponse.errorCode = handler.infoDTO?.errorCode
        bsanSoapResponse.errorDesc = handler.infoDTO?.errorDesc
        bsanSoapResponse.codInfo = handler.infoDTO?.codInfo

        if bsanSoapResponse.errorCode == BSANSoapResponse.RESULT_ERROR {
            if let errorDesc = bsanSoapResponse.errorDesc {
                if errorDesc.contains(WORKAROUND_OK) {
                    bsanSoapResponse.errorCode = BSANSoapResponse.RESULT_OK
                    return false
                }
            }
        }
        
        if let infoDTO = handler.infoDTO, infoDTO.fault {
            bsanSoapResponse.fault = true
            if bsanSoapResponse.errorCode == nil {
                bsanSoapResponse.errorCode = BSANSoapResponse.RESULT_ERROR
            }
            return true
        }
        
        if handler.infoDTO?.errorCode == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            if bsanSoapResponse.errorCode == nil {
                bsanSoapResponse.errorCode = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            }
            return false
        }
        
        bsanSoapResponse.errorCode = BSANSoapResponse.RESULT_OK
        return false
    }

    func setResponseData() {
        fatalError()
    }

    func instanceHandler() -> Handler {
        return Handler.init()
    }

}
