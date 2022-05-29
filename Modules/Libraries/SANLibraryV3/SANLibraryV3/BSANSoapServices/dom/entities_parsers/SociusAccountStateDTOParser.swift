import Foundation
import Fuzi

class SociusAccountStateDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> SociusAccountStateDTO {
        var sociusAccountStateDTO = SociusAccountStateDTO()
        sociusAccountStateDTO.code = node.firstChild(tag:"codigo")?.stringValue.trim()
        sociusAccountStateDTO.literal = node.firstChild(tag:"literal")?.stringValue.trim()
        return sociusAccountStateDTO
    }
}
