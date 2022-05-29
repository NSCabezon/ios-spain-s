import Foundation
import Fuzi

class IBANDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> IBANDTO {
        var ibanDTO = IBANDTO()
        ibanDTO.countryCode = node.firstChild(tag:"PAIS")?.stringValue.trim() ?? ""
        ibanDTO.checkDigits = node.firstChild(tag:"DIGITO_DE_CONTROL")?.stringValue.trim() ?? ""
        ibanDTO.codBban = node.firstChild(tag:"CODBBAN")?.stringValue.trim() ?? ""
        return ibanDTO
    }
}
