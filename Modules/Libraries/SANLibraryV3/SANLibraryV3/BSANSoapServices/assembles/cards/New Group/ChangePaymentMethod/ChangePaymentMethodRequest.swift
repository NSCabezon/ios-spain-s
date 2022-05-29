import Foundation

public class ChangePaymentMethodRequest: BSANSoapRequest<ChangePaymentMethodRequestParams, ChangePaymentMethodHandler, ChangePaymentMethodResponse, ChangePaymentMethodParser> {
    
    public static let SERVICE_NAME = "consultaCambioFormaPago_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Cambioformapago_la/F_tarsan_cambioformapago_la/internet/"
    }
    
    public override var serviceName: String {
        return ChangePaymentMethodRequest.SERVICE_NAME
    }
    
    override var message: String {
        let msg: String =
              "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "  <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>"
            + "  <soapenv:Body>"
            + "    <v1:\(serviceName) facade=\"\(facade)\">"
            + "      <entrada>"
            + "        <contratoTarjeta>"
            + "          <CENTRO>"
            + "             <EMPRESA>\(params.bankCode)</EMPRESA>"
            + "             <CENTRO>\(params.branchCode)</CENTRO>"
            + "          </CENTRO>"
            + "          <PRODUCTO>\(params.product)</PRODUCTO>"
            + "          <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>"
            + "        </contratoTarjeta>"
            + "      </entrada>"
            + "      <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>"
            + "      <datosCabecera>"
            + "        <idioma>"
            + "          <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>"
            + "          <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>"
            + "        </idioma>"
            + "        <empresaAsociada>\(params.linkedCompany)</empresaAsociada>"
            + "      </datosCabecera>"
            + "    </v1:consultaCambioFormaPago_LA>"
            + "  </soapenv:Body>"
            + "</soapenv:Envelope>"
        
        return msg
    }
    
}
