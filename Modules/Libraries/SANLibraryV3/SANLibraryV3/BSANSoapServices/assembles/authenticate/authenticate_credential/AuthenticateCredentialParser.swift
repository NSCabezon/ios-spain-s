import Foundation
import Fuzi

public class AuthenticateCredentialParser : BSANParser<AuthenticateCredentialResponse, AuthenticateCredentialHandler> {
    override func setResponseData(){
         response.tokenCredential = handler.tokenCredential
    }
}

public class AuthenticateCredentialHandler: BSANHandler {
    
    var tokenCredential:String!
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "tokenCredential":
            tokenCredential = element.stringValue
        default:
           BSANLogger.e("AuthenticateCredentialParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}

