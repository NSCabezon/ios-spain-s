import Foundation

public class GetPersonDataListRequest: BSANSoapRequest<GetPersonDataListRequestParams, GetPersonDataListHandler, GetPersonDataListResponse, GetPersonDataListParser> {

    private static let SERVICE_NAME = "listaNombresDePersona_LIP"

    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Comunes/F_bamobi_comunes_lip/internet/"
    }

    public override var serviceName: String {
        return GetPersonDataListRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>" +
            "        \(getSecurityHeader(params.token))" +
            "   </soapenv:Header>" +
            "   <soapenv:Body>" +
            "      <v1:\(serviceName) facade=\"\(facade)\">" +
            "         <entrada>" +
            "            <datosCabecera>" +
            "               <version>\(params.version ?? "")</version>" +
            "               <terminalID>\(params.terminalId ?? "")</terminalID>" +
            "               <idioma>\(serviceLanguage(params.language ?? ""))</idioma>" +
            "            </datosCabecera>" +
            "            <datosConexion>" +
            "                \(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")" +
            "            </datosConexion>" +
            "           <lista>\(getAllNumPerson(params.clientDTOs))</lista>" +
            "         </entrada>" +
            "      </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
            "</soapenv:Envelope>"
    }
}

private func getAllNumPerson(_ clients: [ClientDTO]?) -> String {
    guard let clients = clients else {
        return ""
    }
    var result = ""
    for  client in clients {
        let numPersona =
            "           <numPersona>" +
            "                  <TIPO_DE_PERSONA>\(client.personType ?? "")</TIPO_DE_PERSONA>" +
            "                  <CODIGO_DE_PERSONA>\(client.personCode ?? "")</CODIGO_DE_PERSONA>" +
            "           </numPersona>"
        result = result + numPersona
    }
    return result
}

public class GetPersonDataListRequestParams {
    
    public static func createParams(_ token: String) -> GetPersonDataListRequestParams {
        return GetPersonDataListRequestParams(token)
    }
    
    var token: String
    var userDataDTO: UserDataDTO?
    var version: String?
    var terminalId: String?
    var language: String?
    var clientDTOs: [ClientDTO]?
    
    private init(_ token: String) {
        self.token = token
    }
    
    public func setVersion(_ version: String) -> GetPersonDataListRequestParams {
        self.version = version
        return self
    }
    
    public func setTerminalId(_ terminalId: String) -> GetPersonDataListRequestParams {
        self.terminalId = terminalId
        return self
    }
    
    public func setUserDataDTO(_ userDataDTO: UserDataDTO) -> GetPersonDataListRequestParams {
        self.userDataDTO = userDataDTO
        return self
    }
    
    public func setLanguage(_ language: String) -> GetPersonDataListRequestParams {
        self.language = language
        return self
    }
    
    public func setClientDTOs(_ clientDTOs: [ClientDTO]) -> GetPersonDataListRequestParams {
        self.clientDTOs = clientDTOs
        return self
    }
}
