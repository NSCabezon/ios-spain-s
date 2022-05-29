import Foundation
import Fuzi

public class GetStockOrderDetailParser : BSANParser <GetStockOrderDetailResponse, GetStockOrderDetailHandler> {
    override func setResponseData(){
        response.orderDetailDTO = handler.orderDetailDTO
    }
}

public class GetStockOrderDetailHandler: BSANHandler {
    
    var orderDetailDTO = OrderDetailDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        if let orden = result.firstChild(tag: "orden"){
            if let datosBasicos = orden.firstChild(tag: "datosBasicos"){
                if let fechaOrdenValores = datosBasicos.firstChild(tag: "fechaOrdenValores"){
                    orderDetailDTO.updatedOrderDate = DateFormats.safeDate(fechaOrdenValores.stringValue)
                }
            }
            if let nombreValor = orden.firstChild(tag: "nombreValor"){
                orderDetailDTO.stockName = nombreValor.stringValue.trim()
            }
            if let titulosOrdenados = orden.firstChild(tag: "titulosOrdenados"){
                orderDetailDTO.orderedShares = DTOParser.safeInteger(titulosOrdenados.stringValue.trim())
            }
            if let titulosPendientes = orden.firstChild(tag: "titulosPendientes"){
                orderDetailDTO.pendingShares = DTOParser.safeInteger(titulosPendientes.stringValue)
            }
            if let cambio = orden.firstChild(tag: "cambio"){
                orderDetailDTO.exchange = AmountDTOParser.parse(cambio)
            }
            if let fechaLimite = orden.firstChild(tag: "fechaLimite"){
                orderDetailDTO.limitDate = DateFormats.safeDate(fechaLimite.stringValue.trim())
            }
        }
        
        if let datosFirma = result.firstChild(tag: "datosFirma"){
            orderDetailDTO.signatureDTO = SignatureDTOParser.parse(datosFirma)
        }
        
        if let titular = result.firstChild(tag: "titular"){
            orderDetailDTO.holder = titular.stringValue.trim()
        }
    }
}
