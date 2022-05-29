public class TouchIdRegisterRequest: BSANSoapRequest <TouchIdRegisterRequestParams, TouchIdRegisterHandler, TouchIdRegisterResponse, TouchIdRegisterParser> {
    
    public static let SERVICE_NAME = "registrarDispositivo_LA"
    
    public override var serviceName: String {
        return TouchIdRegisterRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/ACSIC1/Accesosinclave_la/F_acsic1_accesosinclave_la/internet/"
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\n" +
            "        \(getSecurityHeader(params.token))" +
            "    </soapenv:Header>\n" +
            "    <soapenv:Body>\n" +
            "        <v1:registrarDispositivo_LA facade=\"\(facade)\">\n" +
            "            <datosEntrada>\n" +
            "                <footPrint>\(params.footPrint)</footPrint>\n" +
            "                <mobileSO>1</mobileSO>\n" +
            "                <aliasDisp>\(params.deviceName)</aliasDisp>\n" +
            "            </datosEntrada>\n" +
            "            <datosCabecera>\n" +
            "                <version>\(params.version)</version>\n" +
            "                <terminalID>\(params.terminalId)</terminalID>\n" +
            "                <idioma>\(serviceLanguage(params.language))</idioma>\n" +
            "            </datosCabecera>\n" +
            "            <datosConexion>\n" +
            "                \(params.userDataDTO.datosUsuarioWithEmpresa)" +
            "            </datosConexion>\n" +
            "        </v1:registrarDispositivo_LA>\n" +
            "    </soapenv:Body>\n" +
        "</soapenv:Envelope>"
    }
}
