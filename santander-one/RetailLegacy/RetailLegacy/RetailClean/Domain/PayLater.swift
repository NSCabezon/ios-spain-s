import Foundation
import SANLegacyLibrary

struct PayLater {
    let dto: PayLaterDTO
    
    var enrollmentDate: Date? {
        return dto.enrollmentDate
    }
    
    var holderName: String? {
        return dto.holderName
    }
    
    var paymentMethodDesc: String? {
        return dto.paymentMethodDesc
    }
    
    var productName: String? {
        return dto.productName
    }
    
    var situationDesc: String? {
        return dto.situationDesc
    }
}
