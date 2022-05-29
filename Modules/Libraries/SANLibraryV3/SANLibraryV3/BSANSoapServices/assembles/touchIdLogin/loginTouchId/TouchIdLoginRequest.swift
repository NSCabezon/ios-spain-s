public class TouchIdLoginRequest: BSANSoapRequest <TouchIdLoginRequestParams, TouchIdLoginHandler, TouchIdLoginResponse, TouchIdLoginParser> {
    public static let SERVICE_NAME = "autenticaDispositivo_LA"
    
    public override var serviceName: String {
        return TouchIdLoginRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/ACSIC1/Accesosinclave_la/F_acsic1_accesosinclave_la/internet/"
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "  <soapenv:Header/>\n" +
            "  <soapenv:Body>\n" +
            "    <v1:autenticaDispositivo_LA facade=\"\(facade)\">\n" +
            "      <datosEntrada>\n" +
            "        <deviceToken>\(params.deviceToken)</deviceToken>\n" +
            "        <footPrint>\(params.footPrint)</footPrint>\n" +
            "        <documento>\n" +
            "          <TIPO_DOCUM_PERSONA_CORP>\(params.userLoginType)</TIPO_DOCUM_PERSONA_CORP>\n" +
            "          <CODIGO_DOCUM_PERSONA_CORP>\(params.userLogin)</CODIGO_DOCUM_PERSONA_CORP>\n" +
            "        </documento>\n" +
            "        <canalMarco>\(params.channel)</canalMarco>\n" +
            "      </datosEntrada>\n" +
            "      <datosCabecera>\n" +
            "        <idioma>\n" +
            "          <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>\n" +
            "          <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>\n" +
            "        </idioma>\n" +
            "        <empresaAsociada>\(params.linkedCompany)</empresaAsociada>\n" +
            "      </datosCabecera>\n" +
            "    </v1:autenticaDispositivo_LA>\n" +
            "  </soapenv:Body>\n" +
        "</soapenv:Envelope>"
    }
}
