import SANLegacyLibrary
import Foundation

class OrderDetail: GenericProduct {
    
    let orderDetailDTO: OrderDetailDTO
    
    var signature: Signature? {
        guard let signatureDTO = orderDetailDTO.signatureDTO else {
            return nil
        }
        return Signature(dto: signatureDTO)
    }
    
    static func create(from dto: OrderDetailDTO) -> OrderDetail {
        return OrderDetail(from: dto)
    }

    private init(from dto: OrderDetailDTO) {
        self.orderDetailDTO = dto
        super.init()
    }
    
    var stockName: String? {
        return orderDetailDTO.stockName
    }
    
    var orderShares: String {
        guard let orderedShares = orderDetailDTO.orderedShares else { return "" }
        return String(orderedShares)
    }
    
    var pendingShares: String {
        guard let pendingShares =  orderDetailDTO.pendingShares else { return "" }
        return String(pendingShares)
    }
    
    var exchange: String {
        return  Amount.createFromDTO(orderDetailDTO.exchange).getFormattedAmountUI(4)
    }
    
    var limitDate: Date? {
        return orderDetailDTO.limitDate
    }
    
    var signatureDTO: Signature? {
        guard let signatureDTO = orderDetailDTO.signatureDTO else { return nil }
        return Signature(dto: signatureDTO)
    }
    
    var holder: String {
        return orderDetailDTO.holder ?? ""
    }
}

extension OrderDetail: OperativeParameter {}
