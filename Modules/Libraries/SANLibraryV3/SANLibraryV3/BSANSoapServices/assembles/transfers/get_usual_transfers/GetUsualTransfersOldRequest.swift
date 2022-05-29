import Foundation

public class GetUsualTransfersOldRequest: BSANSoapRequest<GetUsualTransfersOldRequestParams, GetUsualTransfersOldHandler, GetUsualTransfersResponse, GetUsualTransfersOldParser> {

    private static let SERVICE_NAME = "busquedaPayeesSEPA_LA"

    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Transfcobrossepa_la/F_bamobi_transfcobrossepa_la/internet/"
    }

    public override var serviceName: String {
        return GetUsualTransfersOldRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "        <soapenv:Header>" +
            "    \(getSecurityHeader(params.token))" +
            "                </soapenv:Header>" +
            "        <soapenv:Body>" +
            "        <v1:\(serviceName) facade=\"\(facade)\">" +
            "        <datosConexion>" +
            "                \(params.userDataDTO.datosUsuarioWithEmpresa)" +
            "                </datosConexion>" +
            "        <datosCabecera>" +
            "        <version>\(params.version)</version>" +
            "        <terminalID>\(params.terminalId)</terminalID>" +
            "        <idioma>\(serviceLanguage(params.language))</idioma>" +
            "        </datosCabecera>" +
            "        </v1:\(serviceName)>" +
            "        </soapenv:Body>" +
        "        </soapenv:Envelope>"
    }
}

public struct GetUsualTransfersOldRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let version: String
    public let terminalId: String
    public let language: String
}
