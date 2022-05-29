public class GetCardPendingTransactionsRequest: BSANSoapRequest <GetCardPendingTransactionsRequestParams, GetCardPendingTransactionsHandler, GetCardPendingTransactionsResponse, GetCardPendingTransactionsParser> {
    public static let SERVICE_NAME = "listaMovtosPdteLiquidar_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Pdteliquidar_la/F_tarsan_pdteliquidar_la/internet/"
    }
    
    public override var serviceName: String {
        return GetCardPendingTransactionsRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>" +
            "    \(getSecurityHeader(params.token))" +
            "   </soapenv:Header>" +
            "   <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "         <entrada>" +
            "            <contratoTarjeta>" +
            "             <CENTRO>" +
            "                 <EMPRESA>\(params.bankCode)</EMPRESA>" +
            "                 <CENTRO>\(params.branchCode)</CENTRO>" +
            "             </CENTRO>" +
            "             <PRODUCTO>\(params.product)</PRODUCTO>" +
            "             <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>" +
            "            </contratoTarjeta>" +
            "            <indicadorRepo>\(params.pagination != nil ? "R" : "L")</indicadorRepo>" +
            "         </entrada>" +
            "          <datosCabecera>" +
            "              <idioma>" +
            "                <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "             </idioma>" +
            "             <empresaAsociada>\(params.linkedCompany)</empresaAsociada>" +
            "          </datosCabecera>" +
            "          <datosConexion>" +
            "          \(params.userDataDTO.datosUsuarioWithEmpresa)" +
            "          </datosConexion>" +
            "                \(params.pagination?.repositionXML ?? "<repos></repos>")" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
    
}
