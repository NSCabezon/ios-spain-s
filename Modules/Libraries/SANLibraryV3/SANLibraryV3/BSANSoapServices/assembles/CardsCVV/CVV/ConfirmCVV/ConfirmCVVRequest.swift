import Foundation
public class ConfirmCVVRequest: BSANSoapRequest <ConfirmCVVRequestParams, ConfirmCVVHandler, ConfirmCVVResponse, ConfirmCVVParser> {
    
    public static let serviceName = "confirmarConsultaDeCVV2_LA"
    
    public override var serviceName: String {
        return ConfirmCVVRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Consultadecvv2_la/F_tarsan_consultadecvv2_la/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        let dateString: String
        if let cardExpirationDate = params.cardExpirationDate {
            dateString = DateFormats.toString(date: cardExpirationDate, output: DateFormats.TimeFormat.yyyyMM)
        } else {
            dateString = ""
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
            "             <codigoOTP>\(params.otpCode)</codigoOTP>" +
            "             <ticket>\(params.otpTicket)</ticket>" +
            "             <token>\(params.otpToken)</token>" +
            "             <numTarjeta>\(params.PAN.replace(" ", ""))</numTarjeta>" +
            "             <caducidadTarjeta>\(dateString)</caducidadTarjeta>" +
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
