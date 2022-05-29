//

import Foundation

public struct ValidateUpdateNoSepaPayeeOTPRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    let signatureWithTokenDTO: SignatureWithTokenDTO
}
