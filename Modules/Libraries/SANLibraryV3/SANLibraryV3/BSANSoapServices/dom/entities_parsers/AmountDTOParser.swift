import Foundation
import Fuzi

class AmountDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> AmountDTO {
        var amountDTO = AmountDTO()
        
        if let importe = node.firstChild(tag: "IMPORTE"){
            amountDTO.value = safeDecimal(importe.stringValue)
        }
        else if let valorLiquidativo = node.firstChild(tag: "VALOR_LIQUIDATIVO"){
            amountDTO.value = safeDecimal(valorLiquidativo.stringValue)
        }
        else if let numeroImportePreciso = node.firstChild(tag: "NUMERO_IMPORTE_PRECISO"){
            amountDTO.value = safeDecimal(numeroImportePreciso.stringValue)
        }
        else if let numeroImporteValores = node.firstChild(tag: "NUMERO_IMPORTE_VALORES"){
            amountDTO.value = safeDecimal(numeroImporteValores.stringValue)
        }
        
        if let currencyName = node.firstChild(tag: "DIVISA")?.stringValue.trim() {
            amountDTO.currency = CurrencyDTO.create(currencyName)
        }
        
        return amountDTO
    }
}
