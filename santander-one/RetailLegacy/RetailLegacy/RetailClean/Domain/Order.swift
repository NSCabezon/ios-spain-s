import SANLegacyLibrary
import Foundation

class Order: GenericProduct {
    
    let orderDTO: OrderDTO
    private var orderDetail: OrderDetail?
    var detailRequestStatus = OrderViewCell.CellState.waitingData
    
    var ticker: String? {
        return orderDTO.ticker
    }
    
    var type: OrderType {
        return orderDTO.operationDescription?.contains("COMPRA") == true ? .buy : .sale
    }
    
    var situation: OrderStatus {
        return OrderStatus.factory(with: orderDTO.situation)
    }
    
    var title: String {
        return orderDetail?.stockName ?? ""
    }
    
    var date: Date? {
        return orderDTO.orderDate
    }
    
    func setDetail(detail: OrderDetail) {
        orderDetail = detail
    }
    
    var number: String {
        return orderDTO.number ?? ""
    }
    static func create(_ from: OrderDTO) -> Order {
        return Order(dto: from)
    }
    
    private init(dto: OrderDTO) {
        orderDTO = dto
        super.init()
    }
}

extension Order: OperativeParameter {}
