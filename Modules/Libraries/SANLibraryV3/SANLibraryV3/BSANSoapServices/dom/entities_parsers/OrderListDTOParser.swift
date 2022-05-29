import Foundation
import Fuzi

class OrderListDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> OrderListDTO {
        var orderListDTO = OrderListDTO()
        
        if node.children(tag: "orden").count == 0{
            return orderListDTO
        }
        
        var orders: [OrderDTO] = []
        
        for i in 0 ... node.children(tag: "orden").count-1{
            let childElement = node.children(tag: "orden")[i]
            let orden = OrderDTOParser.parse(childElement)
            orders.append(orden)
        }
        orderListDTO.orders = orders
        
        return orderListDTO
    }
}
