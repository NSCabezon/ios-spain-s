//

import Foundation

class ApplePayValidationRequest: BSANSoapRequest<ApplePayValidationRequestParams, ApplePayValidationHandler, ApplePayValidationResponse, ApplePayValidationParser> {
    
    static var serviceName = "validaFirmayCreaOtpLA"
    
    override var serviceName: String {
        return ApplePayValidationRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/INAPP/Inappprovisionla/F_inappr_inappprovisionla/ACINAPPRAppelPay/v1"
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
                       <token>\(params.signature.magicPhrase ?? "")</token>
                       <pan>\(params.card.formattedPAN ?? "")</pan>
                       <application>Apple Pay</application>
                       <talg></talg>
                       <datosFirma>
                       \(params.signature.signatureDTO.map(getSignatureXml) ?? "")
                       </datosFirma>
                    </entrada>
                    <datosConexion>
                    \(params.userDataDTO.datosUsuario)
                    </datosConexion>
                    <datosCabecera>
                       <idioma>
                          <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>
                          <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                       </idioma>
                       <empresa>\(params.userDataDTO.company ?? "")</empresa>
                       <empresaAsociada>\(params.linkedCompany)</empresaAsociada>
                    </datosCabecera>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        
        """
    }
}
