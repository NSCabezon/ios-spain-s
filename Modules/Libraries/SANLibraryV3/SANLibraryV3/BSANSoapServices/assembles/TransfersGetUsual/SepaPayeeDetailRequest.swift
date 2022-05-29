public class SepaPayeeDetailRequest: BSANSoapRequest<SepaPayeeDetailRequestParams, SepaPayeeDetailHandler, SepaPayeeDetailResponse, SepaPayeeDetailParser> {
    public static let serviceName = "detallePayeeSepaLa"
    
    public override var serviceName: String {
        return SepaPayeeDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Benefinter_la/F_trasan_benefinter_la/"
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
            + "  \(params.userDataDTO.getUserDataWithMultiChannelAndCompany())"
            + "   <idioma>"
            + "     <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>"
            + "     <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>"
            + "   </idioma>"
            + "  </datosConexion>"
            + "  <entrada>"
            + "    <alias>\(params.alias)</alias>"
            + "    <tipoDestinatario>\(params.recipientType)</tipoDestinatario>"
            + "  </entrada>"
            + " </v1:\(serviceName)>"
            + " </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
}
