import Fuzi

public class TouchIdLoginParser: BSANParser<TouchIdLoginResponse, TouchIdLoginHandler> {
    override func setResponseData() {
        response.touchIdLoginDTO = handler.touchIdLoginDTO
    }
}

public class TouchIdLoginHandler: BSANHandler {
    var touchIdLoginDTO = TouchIdLoginDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "deviceId":
            touchIdLoginDTO.deviceId = element.stringValue.trim()
            
        case "deviceToken":
            touchIdLoginDTO.deviceMagicPhrase = element.stringValue.trim()
            
        case "credenciales":
            var credentialsDTO = CredentialsDTO()
            
            if let cookieCredential = element.firstChild(css: "cookieCredential") {
                credentialsDTO.cookieCredentials = cookieCredential.stringValue.trim()
            }
            
            if let tokenCredential = element.firstChild(css: "tokenCredential") {
                credentialsDTO.tokenCredential = tokenCredential.stringValue.trim()
            }
            
            touchIdLoginDTO.credentialsDTO = credentialsDTO
            
        default:
            break
        }
    }
}
