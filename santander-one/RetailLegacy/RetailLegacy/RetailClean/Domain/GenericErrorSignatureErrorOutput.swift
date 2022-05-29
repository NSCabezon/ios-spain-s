//

import Foundation
import CoreFoundationLib

class GenericErrorSignatureErrorOutput: StringErrorOutput, SignatureErrorProvider {
    let signatureResult: SignatureResult
    let errorCode: String?
    
    init(_ errorDesc: String?, _ signatureResultType: SignatureResult, _ errorCode: String?) {
        self.signatureResult = signatureResultType
        self.errorCode = errorCode
        super.init(errorDesc)
    }
}
