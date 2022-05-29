import SANLegacyLibrary
import Foundation

struct LiquidationItemDetail: GenericTransactionProtocol {
    let dto: LiquidationItemDetailDTO
    
    var validityOpeningDate: Date? {
        return dto.validityOpeningDate
    }
    
    var validityClosingDate: Date? {
        return dto.validityClosingDate
    }
    
    var settlementAmount: Amount {
        return Amount.createFromDTO(dto.settlementAmount)
    }
    
    var liquidationFee: Decimal? {
        return dto.liquidationFee
    }
    
    var liquidationFeeFormatted: String? {
        return dto.liquidationFeeFormatted
    }
    
    var liquidationDescription: String? {
        return dto.liquidationDescription?.camelCasedString ?? ""
    }
}

extension LiquidationItemDetail: Equatable {
    static func == (lhs: LiquidationItemDetail, rhs: LiquidationItemDetail) -> Bool {
        return lhs.liquidationDescription == rhs.liquidationDescription &&
            lhs.validityOpeningDate == rhs.validityOpeningDate &&
            lhs.validityClosingDate == rhs.validityClosingDate &&
            lhs.settlementAmount == rhs.settlementAmount &&
            lhs.liquidationFee == rhs.liquidationFee
    }    
}
