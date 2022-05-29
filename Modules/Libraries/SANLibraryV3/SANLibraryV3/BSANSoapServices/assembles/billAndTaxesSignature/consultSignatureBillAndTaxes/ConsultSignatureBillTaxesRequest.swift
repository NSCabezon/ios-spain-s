public class ConsultSignatureBillTaxesRequest: BSANSoapRequest<ConsultSignatureBillTaxesRequestParams, ConsultSignatureBillTaxesHandler, ConsultSignatureBillTaxesResponse, ConsultSignatureBillTaxesParser>{
    public static let SERVICE_NAME = "signatureBoLStep1"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SIGBRO/Servsigbro_m/F_sigbro_servsign/internet/"
    }
    
    public override var serviceName: String {
        return ConsultSignatureBillTaxesRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "  <soapenv:Header>"
            + "    \(getSecurityHeader(params.token))"
            + "  </soapenv:Header>"
            + "  <soapenv:Body>"
            + "  <v1:\(serviceName) facade=\"\(facade)\">"
            + "  <entrada>"
            + "    <operationData>"
            + "      <canal>\(params.userDataDTO.channelFrame ?? "")</canal>"
            + "      <cuentaOrigen>"
            + "        <CENTRO>"
            + "          <EMPRESA>\(params.chargeAccountBankCode)</EMPRESA>"
            + "          <CENTRO>\(params.chargeAccountBranchCode)</CENTRO>"
            + "        </CENTRO>"
            + "          <PRODUCTO>\(params.chargeAccountProduct)</PRODUCTO>"
            + "          <NUMERO_DE_CONTRATO>\(params.chargeAccountContractNumber)</NUMERO_DE_CONTRATO>"
            + "      </cuentaOrigen>"
            + getCuentaDestino(directDebit: params.directDebit)
            + "      <importe>\(params.amountValueForWS)</importe>"
            + "      <datoOpciona1></datoOpciona1> "
            + "      <datoOpciona2></datoOpciona2> "
            + "      <datoOpciona3></datoOpciona3>"
            + "    </operationData>"
            + "  </entrada>"
            + " </v1:\(serviceName)>"
            + " </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
    
    private func getCuentaDestino(directDebit: Bool) -> String {
        return directDebit ?
                  "      <cuentaDestino>"
                + "        <CENTRO>"
                + "          <EMPRESA>\(params.directDebitAccountBankCode)</EMPRESA>"
                + "          <CENTRO>\(params.directDebitAccountBranchCode)</CENTRO>"
                + "        </CENTRO>"
                + "        <PRODUCTO>\(params.directDebitAccountProduct)</PRODUCTO>"
                + "        <NUMERO_DE_CONTRATO>\(params.directDebitAccountContractNumber)</NUMERO_DE_CONTRATO>"
                + "      </cuentaDestino>"
        : ""
    }
}
