import Foundation
import Fuzi

class PersonDataDTOParser: DTOParser  {
    
    public static func parse(_ node: XMLElement) -> PersonDataDTO {
        var personDataDTO = PersonDataDTO()
        personDataDTO.holder = node.firstChild(tag:"titular")?.stringValue.trim()
        if let clientNode = node.firstChild(tag:"numPersona") {
            personDataDTO.client = ClientDTOParser.parse(clientNode)
        }        
        return personDataDTO
    }
}
