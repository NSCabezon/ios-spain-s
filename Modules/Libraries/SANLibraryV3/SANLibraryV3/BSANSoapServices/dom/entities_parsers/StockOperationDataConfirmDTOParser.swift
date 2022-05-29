import Fuzi

class StockOperationDataConfirmDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> StockOperationDataConfirmDTO {
        var output = StockOperationDataConfirmDTO()
        if let datosBasicosValidacion = node.firstChild(tag: "datosBasicosValidacion"){
            if let fechaNegociacion = datosBasicosValidacion.firstChild(tag: "fechaNegociacion"){
                output.negotiationDate = DateFormats.safeDate(fechaNegociacion.stringValue)
            }
            
            if let horaNegociacion = datosBasicosValidacion.firstChild(tag: "horaNegociacion"){
                output.negotiationTime = DateFormats.safeTime(horaNegociacion.stringValue)
            }
            
            if let numeroOrdenValores = datosBasicosValidacion.firstChild(tag: "numeroOrdenValores"){
                output.stockOrderNumber = numeroOrdenValores.stringValue.trim()
            }
        }
        
        return output
    }
}
