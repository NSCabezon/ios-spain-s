import Foundation

public struct ConfirmOTPLoadPrepaidCardRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var cardDTO: CardDTO
    public var amountDTO: AmountDTO
    public var accountDTO: AccountDTO
    public var prepaidCardDataDTO: PrepaidCardDataDTO
    public var validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO
    public var otpTicket: String
    public var otpToken: String
    public var otpCode: String
}
