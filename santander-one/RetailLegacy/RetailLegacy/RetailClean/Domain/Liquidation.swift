import SANLegacyLibrary
import Foundation

class Liquidation: GenericProduct, GenericTransactionProtocol {
    
    private(set) var dto: LiquidationDTO
    
    init(_ dto: LiquidationDTO) {
        self.dto = dto
    }
    
    var initialDate: Date? {
        return dto.validityOpeningDate
    }
    
    var expirationDate: Date? {
        return dto.validityClosingDate
    }
    
    var liquidationAmount: Amount {
        return Amount.createFromDTO(dto.settlementAmount)
    }
}

extension Liquidation: Equatable {
    static func == (lhs: Liquidation, rhs: Liquidation) -> Bool {
        return lhs.initialDate == rhs.initialDate && lhs.expirationDate == rhs.expirationDate && lhs.liquidationAmount == rhs.liquidationAmount
    }
}
