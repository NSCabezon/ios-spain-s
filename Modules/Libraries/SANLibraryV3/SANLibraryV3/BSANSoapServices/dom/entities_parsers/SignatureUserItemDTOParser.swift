import Foundation
import Fuzi

class SignatureUserItemDTOParser: DTOParser  {
    
    public static func parse(_ node: XMLElement) -> SignatureUserItemDTO {
        var signatureUserItemDTO = SignatureUserItemDTO()
        signatureUserItemDTO.advisoryUserInd = node.firstChild(tag:"indTipoUsuarioConsultivo")?.stringValue.trim()
        signatureUserItemDTO.userOperabilityInd = node.firstChild(tag:"indOperatividadUsuario")?.stringValue.trim()
        return signatureUserItemDTO
    }
}
