//

import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain

struct OTPValidation {
    let otpValidationDTO: OTPValidationDTO

    init(otpValidationDTO: OTPValidationDTO) {
        self.otpValidationDTO = otpValidationDTO
    }
    
    init(_ representable: OTPValidationRepresentable) {
        self.otpValidationDTO = representable as! OTPValidationDTO
    }
    
    var entity: OTPValidationEntity {
        return OTPValidationEntity(otpValidationDTO)
    }
    
    var otpExcepted: Bool {
        return otpValidationDTO.otpExcepted
    }
}
