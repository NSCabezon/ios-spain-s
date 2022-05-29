import Foundation

public class GetBotesPullOffersRequest: BSANSoapRequest<GetBotesPullOffersRequestParams, GetBotesPullOffersHandler, GetBotesPullOffersResponse, GetBotesPullOffersParser> {

    public static let SERVICE_NAME = "consultarCampanyas_LA"

    override var nameSpace: String {
        return "http://www.isban.es/webservices/OFECOM/Ofertascomerciales_la/F_ofecom_ofertascomerciales_la/internet/"
    }

    public override var serviceName: String {
        return GetBotesPullOffersRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "         xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "        <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "           <soapenv:Body>" +
            "               <v1:\(serviceName) facade=\"\(facade)\">" +
            "                  <entrada>" +
            "                      <indicadorEmpresa>4</indicadorEmpresa>" +
            "                      <hueco>0</hueco>" +
            "                   </entrada>" +
            "                   <datosConexion>" +
            "                    \(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")" +
            "                   </datosConexion>" +
            "                   <datosCabecera>" +
            "                       <version>\(params.version ?? "")</version>" +
            "                       <terminalID>\(params.terminalId ?? "")</terminalID>" +
            "                       <idioma>\(serviceLanguage(params.language ?? ""))</idioma>" +
            "                   </datosCabecera>" +
            "               </v1:\(serviceName)>" +
            "        </soapenv:Body>" +
            "</soapenv:Envelope>"
    }    
}


public class GetBotesPullOffersRequestParams {
    
    public static func createParams(_ token: String) -> GetBotesPullOffersRequestParams {
        return GetBotesPullOffersRequestParams(token)
    }
    
    var token: String
    var userDataDTO: UserDataDTO?
    var version: String?
    var terminalId: String?
    var language: String?
    
    private init(_ token: String) {
        self.token = token
    }
    
    public func setVersion(_ version: String) -> GetBotesPullOffersRequestParams {
        self.version = version
        return self
    }
    
    public func setTerminalId(_ terminalId: String) -> GetBotesPullOffersRequestParams {
        self.terminalId = terminalId
        return self
    }
    
    public func setUserDataDTO(_ userDataDTO: UserDataDTO) -> GetBotesPullOffersRequestParams {
        self.userDataDTO = userDataDTO
        return self
    }
    
    public func setLanguage(_ language: String) -> GetBotesPullOffersRequestParams {
        self.language = language
        return self
    }
    
}
