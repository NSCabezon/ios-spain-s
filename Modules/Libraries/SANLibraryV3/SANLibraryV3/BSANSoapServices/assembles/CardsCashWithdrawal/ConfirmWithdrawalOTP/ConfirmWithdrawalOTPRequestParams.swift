import Foundation

public struct ConfirmWithdrawalOTPRequestParams {
    public var token: String
    public var cardToken: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var PAN: String
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var otpTicket: String
    public var otpToken: String
    public var otpCode: String
    public var amount: AmountDTO
    public let trusteerInfo: TrusteerInfoDTO?
}
