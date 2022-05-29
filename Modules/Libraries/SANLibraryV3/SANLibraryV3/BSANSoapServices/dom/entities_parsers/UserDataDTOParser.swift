import Foundation
import Fuzi

class UserDataDTOParser: DTOParser {

    public static  func parse(_ node: XMLElement) -> UserDataDTO {
        var userDataDTO = UserDataDTO()
        
        userDataDTO.company = node.firstChild(tag:"empresa")?.stringValue.trim()
        if let clientNode = node.firstChild(tag:"cliente"){
            userDataDTO.clientPersonType = clientNode.firstChild(tag:"TIPO_DE_PERSONA")?.stringValue.trim()
            userDataDTO.clientPersonCode = clientNode.firstChild(tag:"CODIGO_DE_PERSONA")?.stringValue.trim()
        }
        
        userDataDTO.channelFrame = node.firstChild(tag:"canalMarco")?.stringValue.trim()
        
        if let contractNode = node.firstChild(tag:"contratoMulticanal"){
            userDataDTO.contract = ContractDTOParser.parse(contractNode)
        }
        
        
        return userDataDTO
    }
}
