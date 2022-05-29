import Foundation

public class CheckTransferStatusRequest: BSANSoapRequest <CheckTransferStatusRequestParams, CheckTransferStatusHandler, CheckTransferStatusResponse, CheckTransferStatusParser> {
    
    public static let serviceName = "consultaEstadoTransfInmed_LA"
    
    public override var serviceName: String {
        return CheckTransferStatusRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Inmediatas_la/F_trasan_inmediatas_la/"
    }
    
    override var message: String {
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <datosEntrada>" +
            "                   <ordenReferencia>" +
            "                       <CENTRO>" +
            "                           <EMPRESA>\(params.reference?.getReferencePart1() ?? "")</EMPRESA>" +
            "                           <CENTRO>\(params.reference?.getReferencePart2() ?? "")</CENTRO>" +
            "                       </CENTRO>" +
            "                       <PRODUCTO>\(params.reference?.getReferencePart3() ?? "")</PRODUCTO>" +
            "                       <NUMERO_DE_ORDEN>\(params.reference?.getReferencePart4() ?? "")</NUMERO_DE_ORDEN>" +
            "                   </ordenReferencia>" +
            "               </datosEntrada>" +
            "               <datosCabecera>" +
            "                   <empresa>\(params.linkedCompany)</empresa>" +
            "                   <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "                   </idioma>" +
            "               </datosCabecera>" +
            "               <datosConexion>" +
            "            \(params.userDataDTO.datosUsuarioWithContract)" +
            "               </datosConexion>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
