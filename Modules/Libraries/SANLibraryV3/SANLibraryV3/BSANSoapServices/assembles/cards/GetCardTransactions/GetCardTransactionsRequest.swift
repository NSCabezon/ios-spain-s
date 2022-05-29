import Foundation
public class GetCardTransactionsRequest: BSANSoapRequest <GetCardTransactionsRequestParams, GetCardTransactionsHandler, GetCardTransactionsResponse, GetCardTransactionsParser> {
    
    public static let serviceName = "listaMovTarjetasFechas_LIP"
    
    public override var serviceName: String {
        return GetCardTransactionsRequest.serviceName
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
            "           <entrada>" +
            "               <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "               <datosCabecera>" +
            "                   <version>\(params.version)</version>" +
            "                   <terminalID>\(params.terminalId)</terminalID>" +
            "                   <idioma>\(serviceLanguage(params.language))</idioma>" +
            "               </datosCabecera>" +
            "               <contratoTarjeta>" +
            "                   <PRODUCTO>\(params.product)</PRODUCTO>" +
            "                   <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>" +
            "                   <CENTRO>" +
            "                       <CENTRO>\(params.branchCode)</CENTRO>" +
            "                       <EMPRESA>\(params.bankCode)</EMPRESA>" +
            "                   </CENTRO>" +
            "               </contratoTarjeta>" +
            "               <numeroTarj>\((params.cardPAN))</numeroTarj>" +
            "               \(getDateFilterMessage())" +
            "               <esUnaPaginacion>\(params.pagination != nil ? "S" : "N")</esUnaPaginacion>" +
            "               \(params.pagination?.repositionXML ?? "")" +
            "           </entrada>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
