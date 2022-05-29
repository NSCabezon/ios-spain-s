//

import Foundation

public struct ConfirmCreateNoSepaPayeeRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public var otpToken: String
    public var otpTicket: String
    public var otpCode: String
}
