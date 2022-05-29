import Foundation
import Fuzi

public class ValidateBuyStockTypeOrderParser : BSANParser <ValidateBuyStockTypeOrderResponse, ValidateBuyStockTypeOrderHandler> {
    override func setResponseData(){
        response.stockDataBuyDTO = handler.stockDataBuyDTO
    }
}

public class ValidateBuyStockTypeOrderHandler: BSANHandler {
    
    var stockDataBuyDTO = StockDataBuySellDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        if let saldoCtaAsociada = result.firstChild(tag: "saldoCtaAsociada"){
            stockDataBuyDTO.linkedAccountBalance = AmountDTOParser.parse(saldoCtaAsociada)
        }
        
        if let datosBasicosValidacion = result.firstChild(tag: "datosBasicosValidacion"){
            if let fechaLimite = datosBasicosValidacion.firstChild(tag: "fechaLimite"){
                stockDataBuyDTO.limitDate = DateFormats.safeDate(fechaLimite.stringValue)
            }
            
            if let datosBasicos = datosBasicosValidacion.firstChild(tag: "datosBasicos"){
                if let nombreValor = datosBasicos.firstChild(tag: "nombreValor"){
                    stockDataBuyDTO.nameStock = nombreValor.stringValue.trim()
                }
                
                if let datosFirma = datosBasicos.firstChild(tag: "datosFirma"){
                    stockDataBuyDTO.signature = SignatureDTOParser.parse(datosFirma)
                }
                
                if let titular = datosBasicos.firstChild(tag: "titular"){
                    stockDataBuyDTO.holder = titular.stringValue.trim()
                }
                
                if let descCtaAsociada = datosBasicos.firstChild(tag: "descCtaAsociada"){
                    stockDataBuyDTO.linkedAccountDescription = descCtaAsociada.stringValue.trim()
                }
                
                if let descContrato = datosBasicos.firstChild(tag: "descContrato"){
                    stockDataBuyDTO.descContract = descContrato.stringValue.trim()
                }
            }
        }
    }
}
