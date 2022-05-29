import Foundation

public struct ConfirmPayOffCardRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var cardDTO: CardDTO
    public var linkedAccountContract: ContractDTO?
    public var amountDTO: AmountDTO
    public var signatureWithTokenDTO: SignatureWithTokenDTO
}
