import Fuzi

class TouchIdLoginDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> TouchIdLoginDTO {
        var touchIdLoginDTO = TouchIdLoginDTO()
        
        if let deviceId = node.firstChild(css: "deviceId") {
            touchIdLoginDTO.deviceId = deviceId.stringValue.trim()
        }
        
        if let deviceMagicPhrase = node.firstChild(css: "deviceToken") {
            touchIdLoginDTO.deviceMagicPhrase = deviceMagicPhrase.stringValue.trim()
        }
        
        if let credenciales = node.firstChild(css: "credenciales") {
            var credentialsDTO = CredentialsDTO()
            
            if let cookieCredential = credenciales.firstChild(css: "cookieCredential") {
                credentialsDTO.cookieCredentials = cookieCredential.stringValue.trim()
            }
            
            if let magicPhraseCredential = credenciales.firstChild(css: "tokenCredential") {
                credentialsDTO.tokenCredential = magicPhraseCredential.stringValue.trim()
            }
            touchIdLoginDTO.credentialsDTO = credentialsDTO
        }
        
        return touchIdLoginDTO
    }
}
