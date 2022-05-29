import Foundation

public class GetPortfoliosRequest: BSANSoapRequest<GetPortfoliosRequestParams, GetPortfoliosHandler, GetPortfoliosResponse, GetPortfoliosParser> {

    public static let SERVICE_NAME = "listarCarteras_LA"

    override var facade: String {
        return "ACMOSPPG"
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/MOSPPG/Posicionglobal_la/F_mosppg_posicionglobal_la/internet/"
    }

    public override var serviceName: String {
        return GetPortfoliosRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<v:Envelope xmlns:v=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "xmlns:c=\"http://schemas.xmlsoap.org/soap/encoding/\" " +
            "xmlns:d=\"http://www.w3.org/2001/XMLSchema\" " +
            "xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">" +
            "   <v:Header>\(getSecurityHeader(params.token))</v:Header>" +
            "   <v:Body>" +
            "      <n3:\(serviceName) xmlns:n3=\"\(nameSpace)\(facade)/v1\" facade=\"\(facade)\">" +
            "          <datosConexion>" +
            "          \(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")" +
            "          </datosConexion>" +
            "                <datosCabecera>" +
            "                    <version>\(params.version ?? "")</version>" +
            "                    <terminalID>\(params.terminalId ?? "")</terminalID>" +
            "                    <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO ?? ""))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO ?? "")</DIALECTO_ISO>" +
            "                   </idioma>" +
            "                </datosCabecera>" +
            "      </n3:\(serviceName)>" +
            "   </v:Body>" +
        "</v:Envelope>"
    }
    
}


public class GetPortfoliosRequestParams {
    
    public static func createParams(_ token: String) -> GetPortfoliosRequestParams {
        return GetPortfoliosRequestParams(token)
    }
    
    var token: String
    var version: String?
    var terminalId: String?
    var languageISO: String?
    var userDataDTO: UserDataDTO?
    var dialectISO: String?
    
    private init(_ token: String) {
        self.token = token
    }
    
    public func setVersion(_ version: String) -> GetPortfoliosRequestParams {
        self.version = version
        return self
    }
    
    public func setTerminalId(_ terminalId: String) -> GetPortfoliosRequestParams {
        self.terminalId = terminalId
        return self
    }
    
    public func setUserDataDTO(_ userDataDTO: UserDataDTO) -> GetPortfoliosRequestParams {
        self.userDataDTO = userDataDTO
        return self
    }
    
    public func setLanguageISO(_ languageISO: String) -> GetPortfoliosRequestParams {
        self.languageISO = languageISO
        return self
    }
    
    public func setDialectISO(_ dialectISO: String) -> GetPortfoliosRequestParams {
        self.dialectISO = dialectISO
        return self
    }
}
