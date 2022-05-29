public class ValidationBillTaxesRequest: BSANSoapRequest<ValidationBillTaxesRequestParams, ValidationBillTaxesHandler, ValidationBillTaxesResponse, ValidationBillTaxesParser> {
    public static let serviceName = "validarPagoRecibo_LA"
    
    public override var serviceName: String {
        return ValidationBillTaxesRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/PARETR/Pagorecibos_la/F_paretr_pagorecibos_la/"
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
            + "    <cuentaCargo>"
            + "      <CENTRO>"
            + "        <EMPRESA>\(params.bankCode)</EMPRESA>"
            + "        <CENTRO>\(params.branchCode)</CENTRO>"
            + "      </CENTRO>"
            + "      <PRODUCTO>\(params.product)</PRODUCTO>"
            + "      <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>"
            + "    </cuentaCargo>"
            + "    <centroPago>"
            + "      <EMPRESA>\(BSANHeaderData.DEFAULT_LINKED_COMPANY_SAN_ES_0049)</EMPRESA>"
            + "      <CENTRO/>"
            + "    </centroPago>"
            + "    <datCodBarras>\(params.barCode)</datCodBarras>"
            + "  </entrada>"
            + "  <datosCabecera>"
            + "    <idioma>"
            + "      <IDIOMA_ISO>\(serviceLanguage(BSANHeaderData.DEFAULT_LANGUAGE_ISO_SAN_ES))</IDIOMA_ISO>"
            + "      <DIALECTO_ISO>\(BSANHeaderData.DEFAULT_DIALECT_ISO_SAN_ES)</DIALECTO_ISO>"
            + "    </idioma>"
            + "    <empresaAsociada>\(params.userDataDTO.company ?? "")</empresaAsociada>"
            + "  </datosCabecera>"
            + "  <datosConexion>"
            + "    <canalMarco>\(params.userDataDTO.channelFrame ?? "")</canalMarco>"
            + "    <cliente>"
            + "      <TIPO_DE_PERSONA>\(params.userDataDTO.clientPersonType ?? "")</TIPO_DE_PERSONA>"
            + "      <CODIGO_DE_PERSONA>\(params.userDataDTO.clientPersonCode ?? "")</CODIGO_DE_PERSONA>"
            + "    </cliente>"
            + "  </datosConexion>"
            + " </v1:\(serviceName)>"
            + " </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
    
}
