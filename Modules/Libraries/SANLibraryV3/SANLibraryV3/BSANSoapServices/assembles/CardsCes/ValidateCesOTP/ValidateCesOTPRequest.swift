import Foundation

public class ValidateCesOTPRequest: BSANSoapRequest <ValidateCesOTPRequestParams, ValidateCesOTPHandler, ValidateCesOTPResponse, ValidateCesOTPParser> {
    
    public static let serviceName = "validaAltaTarjetaCesOtpLa"
    
    public override var serviceName: String {
        return ValidateCesOTPRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Alta_ces_la/F_tarsan_alta_ces_la/"
    }
    
    override var message: String {
        let signatureString: String
        if let signature = params.cardSignature {
            signatureString = getSignatureXmlFormatP(signatureDTO: signature)
        } else {
            signatureString = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "           <datosConexion>" +
            "               <idiomaCorporativo>" +
            "                   <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                   <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "               </idiomaCorporativo>" +
            "\(params.contractDTO != nil ? params.userDataDTO.getDatosUsuarioMifid(cmc: params.contractDTO) : "")" +
            "               <empresa>\(params.linkedCompany)</empresa>" +
            "           </datosConexion>" +
            "           <firma>\(signatureString)</firma>" +
            "           <entrada>" +
            "               <tarjeta>\(params.PAN)</tarjeta>" +
            "               <telefono>\(params.phone)</telefono>" +
            "           </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
