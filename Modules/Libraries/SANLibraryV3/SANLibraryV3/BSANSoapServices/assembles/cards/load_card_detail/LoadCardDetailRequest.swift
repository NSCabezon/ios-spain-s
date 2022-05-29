import Foundation

public class LoadCardDetailRequest: BSANSoapRequest<LoadCardDetailRequestParams, LoadCardDetailHandler, LoadCardDetailResponse, LoadCardDetailParser> {

    public static let SERVICE_NAME = "detalleTarjeta_LIP"

    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Tarjetas/F_bamobi_tarjetas_lip/internet/"
    }

    public override var serviceName: String {
        return LoadCardDetailRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\""
            + "        xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "        <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>"
            + "        <soapenv:Body>"
            + "        <v1:\(serviceName) facade=\"\(facade)\">"
            + "        <entrada>"
            + "        <datosConexion>\(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")</datosConexion>"
            + "        <datosCabecera>"
            + "        <version>\(params.version ?? "")</version>"
            + "        <terminalID>\(params.terminalId ?? "")</terminalID>"
            + "        <idioma>\(serviceLanguage(params.language ?? ""))</idioma>"
            + "        </datosCabecera>"
            + "        <numeroTarj>\(params.cardPAN ?? "")</numeroTarj>"
            + "        </entrada>"
            + "        </v1:detalleTarjeta_LIP>"
            + "        </soapenv:Body>"
            + "        </soapenv:Envelope>"
    }
    
}


public class LoadCardDetailRequestParams {
    
    public static func createParams(_ token: String) -> LoadCardDetailRequestParams {
        return LoadCardDetailRequestParams(token)
    }
    
    var token: String
    var userDataDTO: UserDataDTO?
    var version: String?
    var terminalId: String?
    var cardPAN: String?
    var language: String?
    
    private init(_ token: String) {
        self.token = token
    }
    
    public func setUserDataDTO(_ userDataDTO: UserDataDTO) -> LoadCardDetailRequestParams {
        self.userDataDTO = userDataDTO
        return self
    }
    
    public func setVersion(_ version: String) -> LoadCardDetailRequestParams {
        self.version = version
        return self
    }
    
    public func setTerminalId(_ terminalId: String) -> LoadCardDetailRequestParams {
        self.terminalId = terminalId
        return self
    }
    
    public func setCardPAN(_ cardPAN: String) -> LoadCardDetailRequestParams {
        self.cardPAN = cardPAN
        return self
    }
    
    public func setLanguage(_ language: String) -> LoadCardDetailRequestParams {
        self.language = language
        return self
    }
    
    
    
}
