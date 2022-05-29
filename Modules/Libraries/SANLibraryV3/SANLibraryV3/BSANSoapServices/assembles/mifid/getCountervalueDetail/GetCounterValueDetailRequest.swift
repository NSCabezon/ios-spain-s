public class GetCounterValueDetailRequest: BSANSoapRequest<GetCounterValueDetailRequestParams, GetCounterValueDetailHandler, GetCounterValueDetailResponse, GetCounterValueDetailParser> {
    public static let serviceName = "obtenerDetalleContrVal_RMV_LA"
    
    public override var serviceName: String {
        return GetCounterValueDetailRequest.serviceName
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
            + "          <entrada>"
            + "                 <seguridad>"
            + "                     \(params.userDataDTO.getDatosUsuarioMifid(cmc: params.contractDTO))"
            + "                 </seguridad>"
            + "                 <CODIGO_VALOR_LISTA>\(params.stockCode)</CODIGO_VALOR_LISTA>"
            + "                 <CODIGO_EMISION_LISTA>\(params.identificationNumber)</CODIGO_EMISION_LISTA>"
            + "                 <empresa>\(params.userDataDTO.company ?? "")</empresa>"
            + "                 <idioma>"
            + "                     <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>"
            + "                     <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>"
            + "                 </idioma>"
            + "         </entrada>"
            + "      </v1:\(serviceName)>"
            + "    </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
}
