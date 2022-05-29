public class GetPensionContributionsRequest: BSANSoapRequest<GetPensionContributionsRequestParams, GetPensionContributionsHandler, GetPensionContributionsResponse, GetPensionContributionsParser> {
    private static let SERVICE_NAME = "planesAportCapt_LA"
    
    public override var serviceName: String {
        return GetPensionContributionsRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/PLANE1/Aportacionplan_la/F_plane1_aportacionplan_la/"
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>" +
            "        \(getSecurityHeader(params.token))" +
            "   </soapenv:Header>" +
            "   <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "         <entrada>" +
            "            <datosCabecera>" +
            "               <idioma>" +
            "                   <IDIOMA_ISO>\(serviceLanguage(BSANHeaderData.DEFAULT_LANGUAGE_ISO_SAN_ES))</IDIOMA_ISO>" +
            "                   <DIALECTO_ISO>\(BSANHeaderData.DEFAULT_DIALECT_ISO_SAN_ES)</DIALECTO_ISO>" +
            "               </idioma>" +
            "               <empresaAsociada>\(BSANHeaderData.DEFAULT_LINKED_COMPANY_SAN_ES)</empresaAsociada>" +
            "            </datosCabecera>" +
            "            <datosConexion>" +
            "               <cliente>" +
            "                   <TIPO_DE_PERSONA>\(params.userDataDTO.clientPersonType ?? "")</TIPO_DE_PERSONA>" +
            "                   <CODIGO_DE_PERSONA>\(params.userDataDTO.clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
            "               </cliente>" +
            "               <canalMarco>\(params.userDataDTO.channelFrame ?? "")</canalMarco>" +
            "            </datosConexion>" +
            "            <operacion>\(params.pagination != nil ? "R" : "L")</operacion>" +
            "            \(params.pagination?.repositionXML ?? getEmptyRepos())" +
            "            <contratoPlanes>" +
            "            <CENTRO>" +
            "             <EMPRESA>\(params.bankCode)</EMPRESA>" +
            "             <CENTRO>\(params.branchCode)</CENTRO>" +
            "            </CENTRO>" +
            "            <PRODUCTO>\(params.product)</PRODUCTO>" +
            "            <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>" +
            "            </contratoPlanes>" +
            "         </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>";
    }
    
    func getEmptyRepos() -> String{
        return "  <repos>" +
            "      <estatusPlanAport />" +
            "      <fecAltaPlanaport />" +
            "      <tipoPlanAport />" +
            "      <timeStampAltaTabla />" +
        "  </repos>";
    }
}
