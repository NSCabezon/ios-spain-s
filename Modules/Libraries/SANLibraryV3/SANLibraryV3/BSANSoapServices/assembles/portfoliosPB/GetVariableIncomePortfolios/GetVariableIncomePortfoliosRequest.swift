import Foundation

public class GetVariableIncomePortfoliosRequest: BSANSoapRequest<GetVariableIncomePortfoliosRequestParams, GetVariableIncomePortfoliosHandler, GetVariableIncomePortfoliosResponse, GetVariableIncomePortfoliosParser> {

    public static let SERVICE_NAME = "listarCarterasRentaVariable_LA"

    override var facade: String {
        return "ACMOSPCARentaVariable"
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/MOSPCA/Rentavariable_la/F_mospca_rentavariable_la/internet/"
    }

    public override var serviceName: String {
        return GetVariableIncomePortfoliosRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<v:Envelope " +
            "xmlns:v=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "xmlns:c=\"http://schemas.xmlsoap.org/soap/encoding/\" " +
            "xmlns:d=\"http://www.w3.org/2001/XMLSchema\" " +
            "xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">" +
            "   <v:Header>\(getSecurityHeader(params.token))</v:Header>" +
            "   <v:Body>" +
            "      <n3:\(serviceName) xmlns:n3=\"\(nameSpace)\(facade)/v1\" facade=\"\(facade)\">" +
            "          <datosConexion>" +
            "          \(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")" +
            "          </datosConexion>" +
            "          <datosCabecera>" +
            "             <version>\(params.version ?? "")</version>" +
            "             <terminalID>\(params.terminalId ?? "")</terminalID>" +
            "             <idioma>" +
            "                 <IDIOMA_ISO>\(serviceLanguage(params.languageISO ?? ""))</IDIOMA_ISO>" +
            "                 <DIALECTO_ISO>\(params.dialectISO ?? "")</DIALECTO_ISO>" +
            "             </idioma>" +
            "          </datosCabecera>" +
            "      </n3:\(serviceName)>" +
            "   </v:Body>" +
        "</v:Envelope> "
    }
    
}


public class GetVariableIncomePortfoliosRequestParams {
    
    public static func createParams(_ token: String) -> GetVariableIncomePortfoliosRequestParams {
        return GetVariableIncomePortfoliosRequestParams(token)
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
    
    public func setVersion(_ version: String) -> GetVariableIncomePortfoliosRequestParams {
        self.version = version
        return self
    }
    
    public func setTerminalId(_ terminalId: String) -> GetVariableIncomePortfoliosRequestParams {
        self.terminalId = terminalId
        return self
    }
    
    public func setUserDataDTO(_ userDataDTO: UserDataDTO) -> GetVariableIncomePortfoliosRequestParams {
        self.userDataDTO = userDataDTO
        return self
    }
    
    public func setLanguageISO(_ languageISO: String) -> GetVariableIncomePortfoliosRequestParams {
        self.languageISO = languageISO
        return self
    }
    
    public func setDialectISO(_ dialectISO: String) -> GetVariableIncomePortfoliosRequestParams {
        self.dialectISO = dialectISO
        return self
    }
}
