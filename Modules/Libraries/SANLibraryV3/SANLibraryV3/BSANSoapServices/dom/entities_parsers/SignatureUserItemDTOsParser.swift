import Foundation
import Fuzi

class SignatureUserItemDTOsParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [SignatureUserItemDTO] {
        var signatureUserItemDTO:  [SignatureUserItemDTO] = []
        for element in node.children {
            signatureUserItemDTO.append(SignatureUserItemDTOParser.parse(element))
        }
        return signatureUserItemDTO
    }
}
