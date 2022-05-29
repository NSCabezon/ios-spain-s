import Foundation
public class ConfirmPINRequest: BSANSoapRequest <ConfirmPINRequestParams, ConfirmPINHandler, ConfirmPINResponse, ConfirmPINParser> {
    
    public static let serviceName = "confirmarConsultaDePIN_LA"
    
    public override var serviceName: String {
        return ConfirmPINRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Consultadepin_la/F_tarsan_consultadepin_la/internet/"
    }
    
    override var message: String {
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
            "               <token>\(params.otpToken)</token>" +
            "               <ticket>\(params.otpTicket)</ticket>" +
            "               <codigoOTP>\(params.otpCode)</codigoOTP>" +
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
