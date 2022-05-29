public class ValidateMobileRechargeRequest: BSANSoapRequest<ValidateMobileRechargeRequestParams, ValidateMobileRechargeHandler, ValidateMobileRechargeResponse, ValidateMobileRechargeParser>  {
    public static let SERVICE_NAME = "validaRecargaMovilLa"
    
    public override var serviceName: String {
        return ValidateMobileRechargeRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Recargatelefonos_la/F_tarsan_recargatelefonos_la/"
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + " xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "  <soapenv:Header>"
            + "    \(getSecurityHeader(params.token))"
            + "  </soapenv:Header>"
            + "  <soapenv:Body>"
            + "  <v1:\(serviceName) facade=\"\(facade)\">"
            + "  <datosConexion>"
            + "    <idioma>"
            + "      <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>"
            + "      <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>"
            + "    </idioma>"
            + "    <cliente>"
            + "      <TIPO_DE_PERSONA>\(params.userDataDTO.clientPersonType ?? "")</TIPO_DE_PERSONA>"
            + "      <CODIGO_DE_PERSONA>\(params.userDataDTO.clientPersonCode ?? "")</CODIGO_DE_PERSONA>"
            + "    </cliente>"
            + "    <contrato>"
            + "      <CENTRO>"
            + "        <EMPRESA>\(params.cardContract.bankCode ?? "")</EMPRESA>"
            + "        <CENTRO>\(params.cardContract.branchCode ?? "")</CENTRO>"
            + "      </CENTRO>"
            + "      <PRODUCTO>\(params.cardContract.product ?? "")</PRODUCTO>"
            + "      <NUMERO_DE_CONTRATO>\(params.cardContract.contractNumber ?? "")</NUMERO_DE_CONTRATO>"
            + "    </contrato>"
            + "    <canal>\(params.userDataDTO.channelFrame ?? "")</canal>"
            + "    <empresa>\(params.linkedCompany)</empresa>"
            + "  </datosConexion>"
            + "  <tarjeta>"
            + "     <pan>\(params.cardPan)</pan>"
            + "  </tarjeta>"
            + " </v1:\(serviceName)>"
            + " </soapenv:Body>"
            + " </soapenv:Envelope>";
    }
}
