//

import Foundation

public struct ConfirmOperabilityChangeRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let otpToken: String
    public var otpTicket: String
    public var otpCode: String
    public let linkedCompany: String
    public let newOperabilityInd: String
}
