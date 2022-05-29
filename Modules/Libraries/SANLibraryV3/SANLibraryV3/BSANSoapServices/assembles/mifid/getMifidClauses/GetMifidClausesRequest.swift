public class GetMifidClausesRequest: BSANSoapRequest<GetMifidClausesRequestParams, GetMifidClausesHandler, GetMifidClausesResponse, GetMifidClausesParser> {
    public static let SERVICE_NAME = "obtenerClausulasVal_MIFID_LA"
    
    public override var serviceName: String {
        return GetMifidClausesRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/VALORE/Valoresmifid_la/F_valore_valoresmifid_la/internet/"
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + " xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>"
            + "    <soapenv:Body>"
            + "      <v1:\(serviceName) facade=\"\(facade)\">"
            + "             <entrada>"
            + "                 <seguridad>"
            + "                     \(params.userDataDTO.getDatosUsuarioMifid(cmc: params.contractDTO))"
            + "                 </seguridad>"
            + "                 <importeContratacion>"
            + "                     <IMPORTE>1.00</IMPORTE>"
            + "                     <DIVISA>EUR</DIVISA>"
            + "                 </importeContratacion>"
            + "                 <numeroTitulos>\(params.sharesCount)</numeroTitulos>"
            + "                 <emisionValores>"
            + "                     <CODIGO_DE_VALOR>\(params.stockCode)</CODIGO_DE_VALOR>"
            + "                     <CODIGO_DE_EMISION>\(params.identificationNumber)</CODIGO_DE_EMISION>"
            + "                 </emisionValores>"
            + "                 <empresa>\(params.userDataDTO.company ?? "")</empresa>"
            + "                 <idioma>"
            + "                     <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>"
            + "                     <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>"
            + "                 </idioma>"
            + "                 <opcion>\(params.option)</opcion>"
            + "         </entrada>"
            + "      </v1:\(serviceName)>"
            + "    </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
}
