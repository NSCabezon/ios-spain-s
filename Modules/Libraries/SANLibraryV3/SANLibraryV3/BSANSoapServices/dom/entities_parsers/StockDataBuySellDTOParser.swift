import Foundation
import Fuzi

class StockDataBuySellDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> StockDataBuySellDTO {
        var stockDataSellDTO = StockDataBuySellDTO()
        
        if let datosValidacion = node.firstChild(tag: "datosValidacion"){
            if let fechaLimite = datosValidacion.firstChild(tag: "fechaLimite"){
                stockDataSellDTO.limitDate = DateFormats.safeDate(fechaLimite.stringValue)
            }
            
            if let datosBasicos = datosValidacion.firstChild(tag: "datosBasicos"){
                if let nombreValor = datosBasicos.firstChild(tag: "nombreValor"){
                    stockDataSellDTO.nameStock = nombreValor.stringValue.trim()
                }
                
                if let datosFirma = datosBasicos.firstChild(tag: "datosFirma"){
                    stockDataSellDTO.signature = SignatureDTOParser.parse(datosFirma)
                }
                
                if let titular = datosBasicos.firstChild(tag: "titular"){
                    stockDataSellDTO.holder = titular.stringValue.trim()
                }
                
                if let descCtaAsociada = datosBasicos.firstChild(tag: "descCtaAsociada"){
                    stockDataSellDTO.linkedAccountDescription = descCtaAsociada.stringValue.trim()
                }
                
//                if let ctaAsociada = datosBasicos.firstChild(tag: "ctaAsociada"){
                    //                            stockDataSellDTO.holder = descCtaAsociada.stringValue.trim()
//                }
                
                if let descContrato = datosBasicos.firstChild(tag: "descContrato"){
                    stockDataSellDTO.descContract = descContrato.stringValue.trim()
                }
            }
        }
        
        return stockDataSellDTO
    }
}
