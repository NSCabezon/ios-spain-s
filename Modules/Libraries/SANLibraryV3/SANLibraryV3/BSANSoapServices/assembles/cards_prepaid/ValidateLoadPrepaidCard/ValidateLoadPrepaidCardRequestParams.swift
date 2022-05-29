import Foundation

public struct ValidateLoadPrepaidCardRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var cardDTO: CardDTO
    public var amountDTO: AmountDTO
    public var accountDTO: AccountDTO
    public var prepaidCardDataDTO: PrepaidCardDataDTO
}
