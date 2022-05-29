import Foundation

public class UserSegmentRequest: BSANSoapRequest<UserSegmentRequestParams, UserSegmentHandler, UserSegmentResponse, UserSegmentParser> {

    private static let SERVICE_NAME = "obtSegEstructyComerMOV_LIP";

    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Posicionglobal_lip/F_bamobi_posicionglobal_lip/internet/"
    }

    public override var serviceName: String {
        return UserSegmentRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>"
            + "     <soapenv:Body>"
            + "        <v1:obtSegEstructyComerMOV_LIP facade=\"\(facade)\">"
            + "           <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>"
            + "           <datosCabecera>"
            + "              <version>\(params.version)</version>"
            + "              <terminalID>\(params.terminalId)</terminalID>"
            + "              <idioma>\(serviceLanguage(params.language))</idioma>"
            + "           </datosCabecera>"
            + "        </v1:obtSegEstructyComerMOV_LIP>"
            + "     </soapenv:Body>"
            + "  </soapenv:Envelope>"
    }
    
}


public struct UserSegmentRequestParams {
    public let token: String
    public let version: String
    public let terminalId: String
    public let language: String
    public let userDataDTO: UserDataDTO
}
