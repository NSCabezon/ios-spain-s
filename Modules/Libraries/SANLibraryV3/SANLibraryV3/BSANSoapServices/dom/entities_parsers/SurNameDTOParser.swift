import Foundation
import Fuzi

class SurNameDTOParser: DTOParser  {
    
    public static func parse(_ node: XMLElement) -> SurNameDTO {
        var surNameDTO = SurNameDTO()
        surNameDTO.particle = node.firstChild(tag:"PARTICULA")?.stringValue.trim() ?? ""
        surNameDTO.surname = node.firstChild(tag:"APELLIDO")?.stringValue.trim()  ?? ""
        return surNameDTO
    }
}
