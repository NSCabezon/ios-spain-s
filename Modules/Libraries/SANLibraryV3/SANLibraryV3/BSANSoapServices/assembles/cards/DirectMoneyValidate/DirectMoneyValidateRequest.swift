import Foundation
public class DirectMoneyValidateRequest: BSANSoapRequest <DirectMoneyValidateRequestParams, DirectMoneyValidateHandler, DirectMoneyValidateResponse, DirectMoneyValidateParser> {
    
    public static let serviceName = "validarDineroDirecto_LIP"
    
    public override var serviceName: String {
        return DirectMoneyValidateRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Tarjetas/F_bamobi_tarjetas_lip/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "           <datosCabecera>" +
            "               <version>\(params.version)</version>" +
            "               <terminalID>\(params.terminalId)</terminalID>" +
            "               <idioma>\(serviceLanguage(params.language))</idioma>" +
            "           </datosCabecera>" +
            "           <entrada>" +
            "               <importeParteEntera>\(params.directMoneyWholePart)</importeParteEntera>" +
            "               <importeParteDecimal>\(params.directMoneyDecimalPart)</importeParteDecimal>" +
            "               <contratoTarjeta>" +
            "                   <PRODUCTO>\(params.cardContractProduct)</PRODUCTO>" +
            "                   <NUMERO_DE_CONTRATO>\(params.cardContractNumber)</NUMERO_DE_CONTRATO>" +
            "                   <CENTRO>" +
            "                       <CENTRO>\(params.cardContractBranchCode)</CENTRO>" +
            "                       <EMPRESA>\(params.cardContractBankCode)</EMPRESA>" +
            "                   </CENTRO>" +
            "               </contratoTarjeta>" +
            "           </entrada>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
    
}
