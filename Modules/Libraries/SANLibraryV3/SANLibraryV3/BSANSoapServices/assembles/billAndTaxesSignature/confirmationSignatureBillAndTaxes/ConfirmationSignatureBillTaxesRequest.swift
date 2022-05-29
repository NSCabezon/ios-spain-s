public class ConfirmationSignatureBillTaxesRequest: BSANSoapRequest<ConfirmationSignatureBillTaxesRequestParams, ConfirmationSignatureBillTaxesHandler, ConfirmationSignatureBillTaxesResponse, ConfirmationSignatureBillTaxesParser> {
    public static let SERVICE_NAME = "signatureBoLStep2"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SIGBRO/Servsigbro_m/F_sigbro_servsign/internet/"
    }
    
    public override var serviceName: String {
        return ConfirmationSignatureBillTaxesRequest.SERVICE_NAME
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
            + "    <dataToken>\(params.signatureToken)</dataToken>"
            + "    <signaturePositionsValues>\(params.signaturePositionsValues)</signaturePositionsValues>"
            + "  </entrada>"
            + " </v1:\(serviceName)>"
            + " </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
}
