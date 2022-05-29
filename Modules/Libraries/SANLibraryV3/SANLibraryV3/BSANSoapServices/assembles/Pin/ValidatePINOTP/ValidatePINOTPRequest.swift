import Foundation
public class ValidatePINOTPRequest: BSANSoapRequest <ValidatePINOTPRequestParams, ValidatePINOTPHandler, ValidatePINOTPResponse, ValidatePINOTPParser> {
    
    public static let serviceName = "validarConsultaDePINOTP_LA"
    
    public override var serviceName: String {
        return ValidatePINOTPRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Consultadepin_la/F_tarsan_consultadepin_la/internet/"
    }
    
    override var message: String {
        let signatureString: String
        if let signature = params.cardSignature {
            signatureString = FieldsUtils.getSignatureXml(signatureDTO: signature)
        } else {
            signatureString = ""
        }
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <entrada>" +
            "               <contratoTarjeta>" +
            "                   <PRODUCTO>\(params.product)</PRODUCTO>" +
            "                   <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>" +
            "                   <CENTRO>" +
            "                       <CENTRO>\(params.branchCode)</CENTRO>" +
            "                       <EMPRESA>\(params.bankCode)</EMPRESA>" +
            "                   </CENTRO>" +
            "               </contratoTarjeta>" +
            "               <numTarjeta>\(params.PAN)</numTarjeta>" +
            "               <token>\(params.cardToken)</token>" +
            "               <datosFirma>\(signatureString)</datosFirma>" +
            "           </entrada>" +
            "           <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "           <datosCabecera>" +
            "               <idioma>" +
            "                   <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                   <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "               </idioma>" +
            "               <empresaAsociada>\(params.linkedCompany)</empresaAsociada>" +
            "           </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
    
}
