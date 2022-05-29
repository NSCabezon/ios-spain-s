import Foundation
import Fuzi

class OrderDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> OrderDTO {
        var orderDTO = OrderDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "datosBasicos":
                    if let fechaOrdenValores = element.firstChild(tag: "fechaOrdenValores"){
                        orderDTO.orderDate = DateFormats.safeDate(fechaOrdenValores.stringValue)
                    }
                    if let tickerValor = element.firstChild(tag: "tickerValor"){
                        orderDTO.ticker = tickerValor.stringValue.trim()
                    }
                    if let descOperacionValores = element.firstChild(tag: "descOperacionValores"){
                        orderDTO.operationDescription = descOperacionValores.stringValue.trim()
                    }
                    if let descSituacionOrdenValores = element.firstChild(tag: "descSituacionOrdenValores"){
                        orderDTO.situation = descSituacionOrdenValores.stringValue.trim()
                    }
                case "numeroOrdenValores":
                    orderDTO.number = element.stringValue.trim()
                default:
                    BSANLogger.e("FileTypeDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return orderDTO
    }
}
