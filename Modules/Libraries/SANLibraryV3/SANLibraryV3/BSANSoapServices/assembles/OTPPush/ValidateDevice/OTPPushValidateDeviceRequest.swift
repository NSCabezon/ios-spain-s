//

import Foundation

class OTPPushValidateDeviceRequest: BSANSoapRequest<OTPPushValidateDeviceRequestParams, OTPPushValidateDeviceHandler, OTPPushValidateDeviceResponse, OTPPushValidateDeviceParser> {
    
    static var serviceName = "validaDispositivoLa"
    
    override var serviceName: String {
        return OTPPushValidateDeviceRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SUPOTE/Altaote_la/F_supote_altaote_la/ACSUPOTEAltaOTE/v1"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                    <entrada>
                        \(params.userDataDTO.getUserDataWithChannelAndCompany)
                        <idioma>
                            <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>
                            <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>
                        </idioma>
                        <tokenDispositivo>\(params.deviceToken)</tokenDispositivo>
                    </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
