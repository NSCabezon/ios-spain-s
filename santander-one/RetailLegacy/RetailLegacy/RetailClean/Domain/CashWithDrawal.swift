import SANLegacyLibrary

import Foundation

struct CashWithDrawal {
    let dto: CashWithDrawalDTO
    var codQR: String?
    
    init(dto: CashWithDrawalDTO) {
        self.dto = dto
        self.codQR = self.dto.decryptedDataDTO?.codQR ?? ""
    }
    
    var code: String {
        return dto.decryptedDataDTO?.claveSC ?? ""
    }
    
    var date: String {
        return dto.expirationDate ?? ""
    }
    
    var fee: Amount {
        return Amount.zero()
    }
    
    var phone: String {
        return dto.decryptedDataDTO?.telefonoOTP ?? ""
    }
}

extension CashWithDrawal: OperativeParameter {}
