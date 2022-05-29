import Foundation
import Fuzi

class SubproductCodeDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> SubproductCodeDTO {
        var subproductCode = SubproductCodeDTO()
        
        if let tipoProducto = node.firstChild(tag: "TIPO_DE_PRODUCTO"){
            if let empresa = tipoProducto.firstChild(tag: "EMPRESA"){
                subproductCode.company = empresa.stringValue
            }
            if let tipoProductoChild = tipoProducto.firstChild(tag: "TIPO_DE_PRODUCTO"){
                subproductCode.company = tipoProductoChild.stringValue
            }
        }
        if let subtipoProducto = node.firstChild(tag: "SUBTIPO_DE_PRODUCTO"){
            subproductCode.productSubtype = subtipoProducto.stringValue
        }
        
        return subproductCode
    }
}
