import Foundation
import SANLegacyLibrary

struct Amortization {
    let dto: AmortizationDTO
    
    var nextAmortizationDate: Date? {
        return dto.nextAmortizationDate
    }
    var interestAmount: Amount {
        return Amount.createFromDTO(dto.interestAmount)
    }
    var totalFeeAmount: Amount {
        return Amount.createFromDTO(dto.totalFeeAmount)
    }
    var amortizedAmount: Amount {
        return Amount.createFromDTO(dto.amortizedAmount)
    }
    var pendingAmount: Amount {
        return Amount.createFromDTO(dto.pendingAmount)
    }
}
