import Foundation

public struct GetHolderDetailRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var terminalId: String
    public var version: String
    public var languageISO: String
    public var dialectISO: String
    public var portfolioId: String
    public var portfolioTypeInd : String
}
