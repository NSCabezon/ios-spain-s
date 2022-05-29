import Fuzi

class SignatureWithTokenDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> SignatureWithTokenDTO {
        var signatureWithTokenDTO = SignatureWithTokenDTO()
        
        if let token = node.firstChild(tag: "token"){
            signatureWithTokenDTO.magicPhrase = token.stringValue.trim()
        }
        
        if let signaturePositions = node.firstChild(tag: "posicionesFirma"),
            let tamanoFirma = node.firstChild(tag: "tamanoFirma") {
            signatureWithTokenDTO.signatureDTO = createSignatureDTO(positions: signaturePositions, signatureLength: tamanoFirma)
        }
        
        if let dataToken = node.firstChild(tag: "dataToken"){
            signatureWithTokenDTO.magicPhrase = dataToken.stringValue.trim()
        }
        
        if let positions = node.firstChild(tag: "positions"),
            let signatureLength = node.firstChild(tag: "signatureLength"){
            signatureWithTokenDTO.signatureDTO = createSignatureDTO(positions: positions, signatureLength: signatureLength)
        }
        
        if let posiciones = node.firstChild(tag: "posiciones"),
            let tamanoFirma = node.firstChild(tag: "tamanoFirma"){
            signatureWithTokenDTO.signatureDTO = createSignatureDTO(positions: posiciones, signatureLength: tamanoFirma)
        }
        
        return signatureWithTokenDTO
    }
    
    private static func createSignatureDTO(positions: XMLElement, signatureLength: XMLElement) -> SignatureDTO{
        var signature = SignatureDTO()
        signature.positions = DTOParser.safePositions(positions.stringValue.trim())
        signature.length = DTOParser.safeInteger(signatureLength.stringValue.trim())
        return signature
    }
}
