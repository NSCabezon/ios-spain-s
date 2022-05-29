import Foundation

public class LoadCardsInactiveRequest: BSANSoapRequest<LoadCardsInactiveRequestParams, LoadCardsInactiveHandler, LoadCardsInactiveResponse, LoadCardsInactiveParser> {

    public static let SERVICE_NAME = "listaTarjetasInactivas_LIP"

    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Tarjetas/F_bamobi_tarjetas_lip/internet/"
    }

    public override var serviceName: String {
        return LoadCardsInactiveRequest.SERVICE_NAME
    }

    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
                + "        xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
                + "        <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>"
                + "        <soapenv:Body>"
                + "            <v1:\(serviceName) facade=\"\(facade)\">"
                + "                \(getInactiveCardTypeRequestXML(params.inactiveCardType))"
                + "                <datosConexion>\(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")</datosConexion>"
                + "                <datosCabecera>"
                + "                    <version>\(params.version ?? "")</version>"
                + "                    <terminalID>\(params.terminalId ?? "")</terminalID>"
                + "                    <idioma>\(serviceLanguage(params.language ?? ""))</idioma>"
                + "                </datosCabecera>"
                + "            </v1:\(serviceName)>"
                + "        </soapenv:Body>"
                + "</soapenv:Envelope>";
    }

    private func getInactiveCardTypeRequestXML(_ inactiveCardType: InactiveCardType?) -> String {
        return "<entrada><indTipoTarjeta>\(inactiveCardType?.type ?? "")</indTipoTarjeta></entrada>"
    }
}


public class LoadCardsInactiveRequestParams {

    public static func createParams(_ token: String) -> LoadCardsInactiveRequestParams {
        return LoadCardsInactiveRequestParams(token)
    }

    var token: String
    var version: String?
    var terminalId: String?
    var userDataDTO: UserDataDTO?
    var inactiveCardType: InactiveCardType?
    var language: String?

    private init(_ token: String) {
        self.token = token
    }

    public func setVersion(_ version: String) -> LoadCardsInactiveRequestParams {
        self.version = version
        return self
    }

    public func setTerminalId(_ terminalId: String) -> LoadCardsInactiveRequestParams {
        self.terminalId = terminalId
        return self
    }

    public func setUserDataDTO(_ userDataDTO: UserDataDTO) -> LoadCardsInactiveRequestParams {
        self.userDataDTO = userDataDTO
        return self
    }

    public func setInactiveCardType(_ inactiveCardType: InactiveCardType) -> LoadCardsInactiveRequestParams {
        self.inactiveCardType = inactiveCardType
        return self
    }

    public func setLanguage(_ language: String) -> LoadCardsInactiveRequestParams {
        self.language = language
        return self
    }

}
