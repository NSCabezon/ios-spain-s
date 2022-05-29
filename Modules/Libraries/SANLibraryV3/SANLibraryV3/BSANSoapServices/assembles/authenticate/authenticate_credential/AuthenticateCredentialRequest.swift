import Foundation

public class AuthenticateCredentialRequest: BSANSoapRequest<AuthenticateCredentialRequestParams, AuthenticateCredentialHandler, AuthenticateCredentialResponse, AuthenticateCredentialParser> {

    private static let IP_HARDCODED = "0.0.0.0"
    public static let SERVICE_NAME = "authenticateCredential"

    public override var serviceName: String {
        return AuthenticateCredentialRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TECHNICAL_FACADES/Security/F_facseg_security/internet/"
    }
    
    override var message: String {

        if (params.userType != UserLoginType.U) {
            return "<v:Envelope xmlns:v=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
                    " xmlns:c=\"http://schemas.xmlsoap.org/soap/encoding/\" " +
                    " xmlns:d=\"http://www.w3.org/2001/XMLSchema\" " +
                    " xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">" +
                    "   <v:Header />" +
                    "   <v:Body>" +
                    "      <n0:authenticateCredential xmlns:n0=\"\(nameSpace)\(facade)/v1\" facade=\"\(facade)\">" +
                    "         <CB_AuthenticationData i:type=\":CB_AuthenticationData\">" +
                    "            <documento i:type=\":documento\">" +
                    "               <CODIGO_DOCUM_PERSONA_CORP i:type=\"d:string\">\(params.login ?? "")</CODIGO_DOCUM_PERSONA_CORP>" +
                    "               <TIPO_DOCUM_PERSONA_CORP i:type=\"d:string\">\(params.userType?.name ?? "")</TIPO_DOCUM_PERSONA_CORP>" +
                    "            </documento>" +
                    "            <password i:type=\"d:string\">\(params.magic ?? "")</password>" +
                    "         </CB_AuthenticationData>" +
                    "         <userAddress i:type=\"d:string\">\(AuthenticateCredentialRequest.IP_HARDCODED)</userAddress>" +
                    "      </n0:authenticateCredential>" +
                    "   </v:Body>" +
                    "</v:Envelope>"
        } else {
            return "<soapenv:Envelope " +
                    "xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
                    "xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
                    "   <soapenv:Header/>" +
                    "   <soapenv:Body>" +
                    "       <v1:authenticateCredential facade=\"\(facade)\">" +
                    "           <CB_AuthenticationData>" +
                    "               <password>\(params.magic ?? "")</password>" +
                    "               <alias>\(params.login ?? "")</alias>" +
                    "           </CB_AuthenticationData>" +
                    "           <userAddress>\(AuthenticateCredentialRequest.IP_HARDCODED)</userAddress>" +
                    "       </v1:authenticateCredential>" +
                    "   </soapenv:Body>" +
                    "</soapenv:Envelope>"
        }
    }
    
    
}

public class AuthenticateCredentialRequestParams {
    
    public static func  createParams() -> AuthenticateCredentialRequestParams {
        return AuthenticateCredentialRequestParams()
    }
    
    var userType: UserLoginType?
    var login: String?
    var magic: String?
    
    
    func setUserType(_ userType: UserLoginType) -> AuthenticateCredentialRequestParams {
        self.userType = userType
        return self
    }
    
    func setLogin(_ login: String) -> AuthenticateCredentialRequestParams {
        self.login = login
        return self
    }
    
    func setMagic(_ magic: String) -> AuthenticateCredentialRequestParams {
        self.magic = magic
        return self
    }
    
    
}
