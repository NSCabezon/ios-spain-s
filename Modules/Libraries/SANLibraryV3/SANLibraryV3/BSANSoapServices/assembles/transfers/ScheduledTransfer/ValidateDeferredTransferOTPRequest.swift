import Foundation

public class ValidateDeferredTransferOTPRequest: BSANSoapRequest<ValidateDeferredTransferOTPRequestParams, ValidateDeferredTransferOTPHandler, ValidateDeferredTransferOTPResponse, ValidateDeferredTransferOTPParser> {
    
    public static let SERVICE_NAME = "validaDiferidasSepaOtpLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return ValidateDeferredTransferOTPRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "   <soapenv:Body>" +
            "      <v1:\(serviceName) facade=\"\(facade)\">" +
            "        <datosConexion>" +
            "            <idioma>" +
            "             <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "               <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "            </idioma>" +
            "               \(params.userDataDTO.getUserDataWithChannelAndCompanyAndMultiContract)" +
            "        </datosConexion>" +
            "             <firma>\(getSignatureXmlFormatP(signatureDTO: params.signatureDTO))</firma>" +
            "             <entrada>" +
            "                <token>\(params.dataToken)</token>" +
            "             </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}


public struct ValidateDeferredTransferOTPRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let signatureDTO: SignatureDTO
    public let dataToken: String
}
