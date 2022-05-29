//

import Foundation

public struct ConfirmScaRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let language: String
    public let dialect: String
    public let tokenOTP: String?
    public let ticketOTP: String?
    public let codeOTP: String
    public let operativeIndicator: ScaOperativeIndicatorDTO
}
