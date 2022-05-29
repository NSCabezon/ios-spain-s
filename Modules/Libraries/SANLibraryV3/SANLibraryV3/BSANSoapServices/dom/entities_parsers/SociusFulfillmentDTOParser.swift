import Foundation
import Fuzi

class SociusFulfillmentDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> SociusFulfillmentDTO {
        var sociusFulfillmentDTO = SociusFulfillmentDTO()
        sociusFulfillmentDTO.comment = node.firstChild(tag:"comentario")?.stringValue.trim()
        sociusFulfillmentDTO.fulfills = safeBoolean(node.firstChild(tag:"literal")?.stringValue)
        return sociusFulfillmentDTO
    }
}
