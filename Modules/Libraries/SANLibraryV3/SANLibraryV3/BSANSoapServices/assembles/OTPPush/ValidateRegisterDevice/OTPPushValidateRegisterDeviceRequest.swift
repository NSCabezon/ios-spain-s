//

import Foundation

class OTPPushValidateRegisterDeviceRequest: BSANSoapRequest<OTPPushValidateRegisterDeviceRequestParams, OTPPushValidateRegisterDeviceHandler, OTPPushValidateRegisterDeviceResponse, OTPPushValidateRegisterDeviceParser> {
    
    static var serviceName = "validaAltaDispositivoLa"
    
    override var serviceName: String {
        return OTPPushValidateRegisterDeviceRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SUPOTE/Altaote_la/F_supote_altaote_la/ACSUPOTEAltaOTE/v1"
    }
    
    override var message: String {
        guard let signature = params.signature.signatureDTO, let magicPhrase = params.signature.magicPhrase else {
            return ""
        }
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
                        <tokenPasos>\(magicPhrase)</tokenPasos>
                    </entrada>
                    <firma>\(getSignatureXmlFormatP(signatureDTO: signature))</firma>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
