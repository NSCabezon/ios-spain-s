//

import Foundation

public struct OTPValidateOperabilityRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let linkedCompany: String
    public let newOperabilityInd: String
    public let signatureWithTokenDTO: SignatureWithTokenDTO
}
