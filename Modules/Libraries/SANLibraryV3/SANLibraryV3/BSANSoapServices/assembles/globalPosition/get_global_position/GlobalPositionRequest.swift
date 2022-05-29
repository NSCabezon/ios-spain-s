import Foundation

public class GlobalPositionRequest: BSANSoapRequest<GlobalPositionRequestParams, GlobalPositionHandler, GlobalPositionResponse, GlobalPositionParser> {

    public static let SERVICE_NAME = "obtenerPosGlobal_LIP"
    public static let SERVICE_NAME_PB = "obtenerPosGlobalConCestasInvers_LIP"

    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Posglobal/F_bamobi_posicionglobal_lip/internet/"
    }

    public override var serviceName: String {
        if (params.isPb) {
            return GlobalPositionRequest.SERVICE_NAME_PB
        } else {
            return GlobalPositionRequest.SERVICE_NAME
        }
    }
    
    override var message: String {
        if params.isPb {
            return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
                " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
                " <soapenv:Header>\(getSecurityHeader(params.token ?? ""))</soapenv:Header>" +
                "    <soapenv:Body>" +
                "        <v1:obtenerPosGlobalConCestasInvers_LIP facade=\"\(facade)\">" +
                "            <entrada>" +
                "                <datosCabecera>" +
                "                    <version>\(params.version ?? "")</version>" +
                "                    <terminalID>\(params.terminalId ?? "")</terminalID>" +
                "                    <idioma>\(serviceLanguage(params.language ?? ""))</idioma>" +
                "                </datosCabecera>" +
                "                <indFiltrarVisibles>\(params.onlyVisibleProducts ?? "")</indFiltrarVisibles>" +
                "            </entrada>" +
                "        </v1:obtenerPosGlobalConCestasInvers_LIP>" +
                "    </soapenv:Body>" +
            "</soapenv:Envelope>"
        } else {
            return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
                "xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
                "<soapenv:Header>\(getSecurityHeader(params.token ?? ""))</soapenv:Header>" +
                "    <soapenv:Body>" +
                "        <v1:obtenerPosGlobal_LIP facade=\"\(facade)\">" +
                "            <entrada>" +
                "                <datosCabecera>" +
                "                    <version>\(params.version ?? "")</version>" +
                "                    <terminalID>\(params.terminalId ?? "")</terminalID>" +
                "                    <idioma>\(serviceLanguage(params.language ?? ""))</idioma>" +
                "                </datosCabecera>" +
                "                <indFiltrarVisibles>\(params.onlyVisibleProducts ?? "")</indFiltrarVisibles>" +
                "            </entrada>" +
                "        </v1:obtenerPosGlobal_LIP>" +
                "    </soapenv:Body>" +
            "</soapenv:Envelope>"
        }
    }
    
}

public class GlobalPositionRequestParams {
    
    public static func  createParams(isPb: Bool) -> GlobalPositionRequestParams {
        return GlobalPositionRequestParams(isPb)
    }
    
    var token: String?
    var terminalId: String?
    var version: String?
    var language: String?
    var onlyVisibleProducts: String?
    var isPb: Bool
    
    private init (_ isPb: Bool) {
        self.isPb = isPb
    }
    
    func setOnlyVisibleProducts(_ onlyVisibleProducts: String) -> GlobalPositionRequestParams {
        self.onlyVisibleProducts = onlyVisibleProducts
        return self
    }
    
    func setToken(_ token: String) -> GlobalPositionRequestParams {
        self.token = token
        return self
    }
    
    func setTerminalId(_ terminalId: String) -> GlobalPositionRequestParams {
        self.terminalId = terminalId
        return self
    }
    
    func setVersion(_ version: String) -> GlobalPositionRequestParams {
        self.version = version
        return self
    }
    
    func setLanguage(_ language: String) -> GlobalPositionRequestParams {
        self.language = language
        return self
    }
}
