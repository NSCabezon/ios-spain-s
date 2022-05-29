import Foundation

public class ValidateCVVOTPRequest: BSANSoapRequest <ValidateCVVOTPRequestParams, ValidateCVVOTPHandler, ValidateCVVOTPResponse, ValidateCVVOTPParser> {
    
    public static let serviceName = "validarConsultaDeCVV2OTP_LA"
    
    public override var serviceName: String {
        return ValidateCVVOTPRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Consultadecvv2_la/F_tarsan_consultadecvv2_la/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        let signatureString: String
        if let signature = params.cardSignature {
            signatureString = FieldsUtils.getSignatureXml(signatureDTO: signature)
        } else {
            signatureString = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "          <entrada>" +
            "             <contratoTarjeta>" +
            "                <CENTRO>" +
            "                   <EMPRESA>\(params.bankCode)</EMPRESA>" +
            "                   <CENTRO>\(params.branchCode)</CENTRO>" +
            "                </CENTRO>" +
            "                <PRODUCTO>\(params.product)</PRODUCTO>" +
            "                <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>" +
            "             </contratoTarjeta>" +
            "             <token>\(params.cardDetailToken)</token>" +
            "             <numTarjeta>\(params.PAN)</numTarjeta>" +
            "             <datosFirma>\(signatureString)</datosFirma>" +
            "          </entrada>" +
            "          <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "          <datosCabecera>" +
            "               <idioma>" +
            "                   <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                   <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "               </idioma>" +
            "               <empresaAsociada>\(params.linkedCompany)</empresaAsociada>" +
            "          </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
    
}
