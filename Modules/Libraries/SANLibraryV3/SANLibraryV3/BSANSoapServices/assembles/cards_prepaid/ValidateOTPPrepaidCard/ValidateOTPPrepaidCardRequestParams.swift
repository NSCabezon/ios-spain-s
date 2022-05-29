import Foundation

public struct ValidateOTPPrepaidCardRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var cardDTO: CardDTO
    public var signatureDTO: SignatureDTO
    public var validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO
}
