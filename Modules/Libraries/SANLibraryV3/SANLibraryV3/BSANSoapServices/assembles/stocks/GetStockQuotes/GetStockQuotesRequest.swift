import Foundation
public class GetStockQuotesRequest: BSANSoapRequest <GetStockQuotesRequestParams, GetStockQuotesHandler, GetStockQuotesResponse, GetStockQuotesParser> {
    
    public static let serviceName = "listaCotizacionesValores_LIP"
    
    public override var serviceName: String {
        return GetStockQuotesRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Valores/F_bamobi_valores_lip/internet/"
    }
    
    override var message: String {
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <datosCabecera>" +
            "                   <version>\(params.version)</version>" +
            "                   <terminalID>\(params.terminalId)</terminalID>" +
            "                   <idioma>\(serviceLanguage(params.language))</idioma>" +
            "               </datosCabecera>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            "               <entrada>" +
            "                   <buscadorValor>\(params.searchString)</buscadorValor>" +
            "               </entrada>" +
            "               <indicadores>" +
            "                   <esUnaPaginacion>\(params.pagination?.endList == false ? "S" : "N")</esUnaPaginacion>" +
            "               </indicadores>" +
            "               \(params.pagination?.repositionXML ?? "")" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
