import Fuzi

class EntityAuthPaymentDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> EntityAuthPaymentDTO {
        var entityAuthPaymentDTO = EntityAuthPaymentDTO()
        
        if let entityDocument = node.firstChild(tag:"documento"){
            var documentAuth = DocumentEntityAuthPaymentDTO()
            documentAuth.type = entityDocument.firstChild(tag:"TIPO_DOCUM_PERSONA_CORP")?.stringValue.trim()
            documentAuth.code = entityDocument.firstChild(tag:"CODIGO_DOCUM_PERSONA_CORP")?.stringValue.trim()
            entityAuthPaymentDTO.document = documentAuth
        }
        entityAuthPaymentDTO.address = node.firstChild(tag:"domicilio")?.stringValue.trim()
        entityAuthPaymentDTO.town = node.firstChild(tag:"localidad")?.stringValue.trim()
        entityAuthPaymentDTO.typeDocumentDescription = node.firstChild(tag:"descTipoDocumento")?.stringValue.trim()
        
        return entityAuthPaymentDTO
    }
}
