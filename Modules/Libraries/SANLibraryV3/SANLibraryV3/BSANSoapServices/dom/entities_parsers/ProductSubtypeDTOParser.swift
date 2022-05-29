import Foundation
import Fuzi

class ProductSubtypeDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> ProductSubtypeDTO {
        var productSubtypeDTO = ProductSubtypeDTO()        
        productSubtypeDTO.productSubtype = node.firstChild(tag:"SUBTIPO_DE_PRODUCTO")?.stringValue.trim()
        if let productTypeNode = node.firstChild(tag:"TIPO_DE_PRODUCTO"){
            productSubtypeDTO.company = productTypeNode.firstChild(tag:"EMPRESA")?.stringValue.trim()
            productSubtypeDTO.productType = productTypeNode.firstChild(tag:"TIPO_DE_PRODUCTO")?.stringValue.trim()
        }
        return productSubtypeDTO
    }
}
