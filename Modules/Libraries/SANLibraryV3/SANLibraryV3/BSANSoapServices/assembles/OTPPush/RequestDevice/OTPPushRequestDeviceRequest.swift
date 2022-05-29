//

import Foundation

class OTPPushRequestDeviceRequest: BSANSoapRequest<OTPPushRequestDeviceRequestParams, OTPPushRequestDeviceHandler, OTPPushRequestDeviceResponse, OTPPushRequestDeviceParser> {
    
    static var serviceName = "consultaDispositivoLa"
    
    override var serviceName: String {
        return OTPPushRequestDeviceRequest.serviceName
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
                        <IDIOMA_ISO>\(serviceLanguage(BSANHeaderData.DEFAULT_LANGUAGE_ISO_SAN_ES))</IDIOMA_ISO>
                        <DIALECTO_ISO>\(BSANHeaderData.DEFAULT_DIALECT_ISO_SAN_ES)</DIALECTO_ISO>
                    </idioma>
                </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
