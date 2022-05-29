public class ConsultSignaturePositionsRequest: BSANSoapRequest<ConsultSignaturePositionsRequestParams, ConsultSignaturePositionsHandler, ConsultSignaturePositionsResponse, ConsultSignaturePositionsParser> {
    public static let SERVICE_NAME = "consultaPosicionesFirma_LA"

    override var nameSpace: String {
        return "http://www.isban.es/webservices/SWENDI/Enviodinero_la/F_swendi_enviodinero_la/internet/"
    }
    
    public override var serviceName: String {
        return ConsultSignaturePositionsRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "       xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "      <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:\(serviceName) facade=\"\(facade)\">" +
            "               <entrada>" +
            "                   <aplicacion>\(params.acronymWsCaller)</aplicacion>" +
            "               </entrada>" +
            "               <datosCabecera>" +
            "                   <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "                   </idioma>" +
            "                   <empresaAsociada>\(params.linkedCompany)</empresaAsociada>" +
            "               </datosCabecera>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            "           </v1:\(serviceName)>" +
            "       </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
    
}
