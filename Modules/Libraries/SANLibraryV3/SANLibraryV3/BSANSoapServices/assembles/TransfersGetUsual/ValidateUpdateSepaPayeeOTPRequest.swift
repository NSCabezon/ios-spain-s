import Foundation

public class ValidateUpdateSepaPayeeOTPRequest: BSANSoapRequest<ValidateUpdateSepaPayeeOTPRequestParams, ValidateUpdateSepaPayeeOTPHandler, ValidateUpdateSepaPayeeOTPResponse, ValidateUpdateSepaPayeeOTPParser> {
    
    static public var serviceName = "firmaModifPayeeSepaLa"
    
    public override var serviceName: String {
        return ValidateUpdateSepaPayeeOTPRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Benefinter_la/F_trasan_benefinter_la/ACTRANSANBenefInterLa/v1"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                    <datosConexion>
                        \(params.userDataDTO.getUserDataWithMultiChannelAndCompany())"
                        <idioma>"
                            <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>"
                            <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>"
                        </idioma>"
                    </datosConexion>
                    <firma>\(params.signatureWithTokenDTO.signatureDTO.map(getSignatureXmlFormatP) ?? "")</firma>
                    <entrada>
                        <token>\(params.signatureWithTokenDTO.magicPhrase ?? "")</token>
                    </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
