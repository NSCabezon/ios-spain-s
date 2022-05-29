public class BillAndTaxesDetailRequest: BSANSoapRequest<BillAndTaxesDetailRequestParams, BillAndTaxesDetailHandler, BillAndTaxesDetailResponse, BillAndTaxesDetailParser> {
    public static let serviceName = "detalleReciboSEPA_LA"
    
    public override var serviceName: String {
        return BillAndTaxesDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/RECSAN/Consrecibos_la/F_recsan_consrecibos_la/internet/"
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "  <soapenv:Header>"
            + "    \(getSecurityHeader(params.token))"
            + "  </soapenv:Header>"
            + "  <soapenv:Body>"
            + "  <v1:\(serviceName) facade=\"\(facade)\">"
            + "  <datosConexion>"
            + "  \(params.userDataDTO.getUserDataWithMarcoChannelAndMultiContract)"
            + "  </datosConexion>"
            + "  <datosCabecera>"
            + "    <idioma>\(serviceLanguage(params.language))</idioma>"
            + "  </datosCabecera>"
            + "  <entrada>"
            + "   <ordenServicio>"
            + "      <CENTRO>"
            + "        <EMPRESA>\(params.billOrderServiceBankCode)</EMPRESA>"
            + "        <CENTRO>\(params.billOrderServiceBranchCode)</CENTRO>"
            + "      </CENTRO>"
            + "      <PRODUCTO>\(params.billOrderServiceProduct)</PRODUCTO>"
            + "      <NUMERO_DE_ORDEN>\(params.billOrderServiceContractNumber)</NUMERO_DE_ORDEN>"
            + "   </ordenServicio>"
            + "   <contratoDomiciliacion>"
            + "      <CENTRO>"
            + "         <EMPRESA>\(params.accountDTO.oldContract?.bankCode ?? "")</EMPRESA>"
            + "         <CENTRO>\(params.accountDTO.oldContract?.branchCode ?? "")</CENTRO>"
            + "      </CENTRO>"
            + "      <PRODUCTO>\(params.accountDTO.oldContract?.product ?? "")</PRODUCTO>"
            + "      <NUMERO_DE_CONTRATO>\(params.accountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>"
            + "   </contratoDomiciliacion>"
            + "  </entrada>"
            + " </v1:\(serviceName)>"
            + " </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
}
