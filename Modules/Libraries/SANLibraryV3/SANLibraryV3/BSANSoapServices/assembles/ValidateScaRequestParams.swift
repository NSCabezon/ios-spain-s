//

import Foundation

public struct ValidateScaRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let language: String
    public let dialect: String
    public let forwardIndicator: Bool
    public let forceSMS: Bool
    public let operativeIndicator: ScaOperativeIndicatorDTO
    public let linkedCompany: String
}
