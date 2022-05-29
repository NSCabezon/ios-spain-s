import Foundation

public struct ConfirmCesOTPRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var otpTicket: String
    public var otpToken: String
    public var otpCode: String
    public var contractDTO: ContractDTO?
}
