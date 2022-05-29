import Foundation
public class ValidateOTPPrepaidCardRequest: BSANSoapRequest <ValidateOTPPrepaidCardRequestParams, ValidateOTPPrepaidCardHandler, ValidateOTPPrepaidCardResponse, ValidateOTPPrepaidCardParser> {
    
    public static let serviceName = "validarCargaDescargaPrepagoOTP_LA"
    
    public override var serviceName: String {
        return ValidateOTPPrepaidCardRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Recargaecash_la/F_tarsan_recargaecash_la/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <entrada>" +
            "               <token>\(params.validateLoadPrepaidCardDTO.token ?? "")</token>" +
            "               <valoresFirma>\(FieldsUtils.getSignatureXml(signatureDTO: params.signatureDTO))</valoresFirma>" +
            "               <contratoTarjeta>" +
            "                   <CENTRO>" +
            "                       <EMPRESA>\(params.cardDTO.contract?.bankCode ?? "")</EMPRESA>" +
            "                       <CENTRO>\(params.cardDTO.contract?.branchCode ?? "")</CENTRO>" +
            "                   </CENTRO>" +
            "                   <PRODUCTO>\(params.cardDTO.contract?.product ?? "")</PRODUCTO>" +
            "                   <NUMERO_DE_CONTRATO>\(params.cardDTO.contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
            "               </contratoTarjeta>" +
            "               <numTarjeta>\(params.cardDTO.PAN ?? "")</numTarjeta>" +
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
