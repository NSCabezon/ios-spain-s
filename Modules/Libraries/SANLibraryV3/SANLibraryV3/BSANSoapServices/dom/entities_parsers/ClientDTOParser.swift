import Foundation
import Fuzi

class ClientDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> ClientDTO {
        var clientDTO = ClientDTO()
        clientDTO.personType = node.firstChild(tag:"TIPO_DE_PERSONA")?.stringValue.trim()
        clientDTO.personCode = node.firstChild(tag:"CODIGO_DE_PERSONA")?.stringValue.trim()
        return clientDTO
    }
}
