import Fuzi

class TouchIdRegisterDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> TouchIdRegisterDTO {
        var touchIdRegisterDTO = TouchIdRegisterDTO()
        
        if let deviceToken = node.firstChild(css: "deviceToken"){
            touchIdRegisterDTO.deviceMagicPhrase = deviceToken.stringValue.trim()
        }
        
        if let deviceId = node.firstChild(css: "deviceId"){
            touchIdRegisterDTO.deviceId = deviceId.stringValue.trim()
        }
        
        return touchIdRegisterDTO
    }
}

