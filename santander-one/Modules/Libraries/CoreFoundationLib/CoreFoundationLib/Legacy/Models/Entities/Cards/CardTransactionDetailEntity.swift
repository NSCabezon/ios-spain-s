import Foundation
import SANLegacyLibrary

public struct CardTransactionDetailEntity: DTOInstantiable {
    
    public let dto: CardTransactionDetailDTO
    
    public init(_ dto: CardTransactionDetailDTO) {
        self.dto = dto
    }
    
    public var isSoldOut: Bool {
        return dto.liquidated ?? false
    }
    
    public var soldOutDate: Date? {
        return dto.liquidationDate
    }
    
    public var bankCharge: AmountEntity? {
        return dto.bankCharge.map(AmountEntity.init)
    }
    
    public var transactionDate: String? {
        return dto.transactionTime
    }
}
