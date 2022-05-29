//

import Foundation
import CoreFoundationLib

class GenericErrorOTPErrorOutput: StringErrorOutput, OTPErrorProvider {
    let otpResult: OTPResult
    let errorCode: String?
    
    init(_ errorDesc: String?, _ otpResultType: OTPResult, _ errorCode: String?) {
        self.otpResult = otpResultType
        self.errorCode = errorCode
        super.init(errorDesc)
    }
}
