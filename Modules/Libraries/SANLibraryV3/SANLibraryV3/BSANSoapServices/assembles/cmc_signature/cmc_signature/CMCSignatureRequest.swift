import Foundation

public class CMCSignatureRequest: BSANSoapRequest<CMCSignatureRequestParams, CMCSignatureHandler, CMCSignatureResponse, CMCSignatureParser> {

    private static let SERVICE_NAME = "consultarCMC_LA"

    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Recargaecash_la/F_tarsan_recargaecash_la/internet/"
    }

    public override var serviceName: String {
        return CMCSignatureRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "    xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "        <v1:\(serviceName) facade=\"\(facade)\">" +
            "            <datosConexion>" +
            "            \(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")" +
            "            </datosConexion>" +
            "            <datosCabecera>" +
            "                <idioma>" +
            "                    <IDIOMA_ISO>\(serviceLanguage(params.languageISO ?? ""))</IDIOMA_ISO>" +
            "                    <DIALECTO_ISO>\(params.dialectISO ?? "")</DIALECTO_ISO>" +
            "                </idioma>" +
            "                <empresaAsociada>\(params.linkedCompany ?? "")</empresaAsociada>" +
            "            </datosCabecera>" +
            "        </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}


public class CMCSignatureRequestParams {
    
    public static func createParams(_ token: String) -> CMCSignatureRequestParams {
        return CMCSignatureRequestParams(token)
    }
    
    var token: String
    var userDataDTO:UserDataDTO?
    var languageISO: String?
    var dialectISO: String?
    var linkedCompany: String?
    
    private init(_ token: String) {
        self.token = token
    }
    
    public func setUserDataDTO(_ userDataDTO: UserDataDTO) -> CMCSignatureRequestParams {
        self.userDataDTO = userDataDTO
        return self
    }
    
    public func setLanguageISO(_ languageISO: String) -> CMCSignatureRequestParams {
        self.languageISO = languageISO
        return self
    }
    
    public func setDialectISO(_ dialectISO: String) -> CMCSignatureRequestParams {
        self.dialectISO = dialectISO
        return self
    }
    
    public func setLinkedCompany(_ linkedCompany: String) -> CMCSignatureRequestParams {
        self.linkedCompany = linkedCompany
        return self
    }
    
}
