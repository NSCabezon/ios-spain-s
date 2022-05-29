import Foundation
public class GetStockQuoteIBEXSANRequest: BSANSoapRequest <GetStockQuoteIBEXSANRequestParams, GetStockQuoteIBEXSANHandler, GetStockQuoteIBEXSANResponse, GetStockQuoteIBEXSANParser> {
    
    public static let serviceName = "detalleCotizacionIBEXySAN_LIP"
    
    public override var serviceName: String {
        return GetStockQuoteIBEXSANRequest.serviceName
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
            "               <entrada>" +
            "                   <datosCabecera>" +
            "                       <version>\(params.version)</version>" +
            "                       <terminalID>\(params.terminalId)</terminalID>" +
            "                       <idioma>\(serviceLanguage(params.language))</idioma>" +
            "                   </datosCabecera>" +
            "                   <datosConexion>\(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")</datosConexion>" +
            "               </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
