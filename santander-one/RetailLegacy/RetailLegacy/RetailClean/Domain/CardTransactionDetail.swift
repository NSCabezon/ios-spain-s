import SANLegacyLibrary
import Foundation

struct CardTransactionDetail {
    
    private(set) var dto: CardTransactionDetailDTO?
    
    init(_ dto: CardTransactionDetailDTO) {
        self.dto = dto
    }
    
    var time: String? {
        return dto?.transactionTime
    }
    
    var fee: Amount? {
        return Amount.createFromDTO(dto?.bankCharge)
    }
    
    var isPaidOff: Bool? {
        return dto?.liquidated
    }
    
    var paidOffDate: Date? {
        return dto?.liquidationDate
    }
}
