import Foundation

public struct GetCardDetailTokenRequestParams {
    public var token: String
    public var version: String
    public var terminalId: String
    public var userDataDTO: UserDataDTO
    public var language: String
    public var cardPAN: String
    public var cardTokenType: CardTokenType
}
