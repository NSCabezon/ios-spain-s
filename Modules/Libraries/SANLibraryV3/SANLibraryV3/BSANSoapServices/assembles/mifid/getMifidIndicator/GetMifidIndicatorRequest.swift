public class GetMifidIndicatorRequest: BSANSoapRequest<GetMifidIndicatorRequestParams, GetMifidIndicatorHandler, GetMifidIndicatorResponse, GetMifidIndicatorParser>  {
    public static let SERVICE_NAME = "consIndicadoresMifid_LA"
    
    public override var serviceName: String {
        return GetMifidIndicatorRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/VALORE/Valoresmifid_la/F_valore_valoresmifid_la/internet/"
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + " xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "    <soapenv:Header>"
            + "    \(getSecurityHeader(params.token))"
            + "    </soapenv:Header>"
            + "    <soapenv:Body>"
            + "      <v1:\(serviceName) facade=\"\(facade)\">"
            + "         <entrada>"
            + "            <seguridad>"
            + "               <canal>INT</canal>"
            + "               \(params.userDataDTO.getDatosUsuarioMifid(cmc: params.contractDTO))"
            + "            </seguridad>"
            + "            <empresaAsociada>\(params.userDataDTO.company ?? "")</empresaAsociada>"
            + "            <idioma>"
            + "               <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>"
            + "               <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>"
            + "            </idioma>"
            + "         </entrada>"
            + "      </v1:\(serviceName)>"
            + "    </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
    
}
