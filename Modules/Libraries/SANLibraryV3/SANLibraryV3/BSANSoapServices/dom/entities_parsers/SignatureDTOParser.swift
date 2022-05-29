import Foundation
import Fuzi

class SignatureDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> SignatureDTO {
        var signatureDTO = SignatureDTO()
        
        if let positions = node.firstChild(tag: "positions"){
            signatureDTO.positions = safePositions(positions.stringValue)
        }
        else if let posiciones = node.firstChild(tag: "posiciones"){
            signatureDTO.positions = safePositions(posiciones.stringValue)
        } else if let positions = node.firstChild(tag: "posicionesFirma") {
            signatureDTO.positions = safePositions(positions.stringValue)
        }
        
        if let signatureLength = node.firstChild(tag: "signatureLength"){
            signatureDTO.length = safeInteger(signatureLength.stringValue)
        } else if let tamanoFirma = node.firstChild(tag: "tamanoFirma"){
            signatureDTO.length = safeInteger(tamanoFirma.stringValue)
        } else if let signatureLength = node.firstChild(tag: "signaturelength"){
            signatureDTO.length = safeInteger(signatureLength.stringValue)
        }
        
        return signatureDTO
    }
}
