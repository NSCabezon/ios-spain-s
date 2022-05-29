import Foundation

public struct GetProductTransactionDetailRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var terminalId: String
    public var version: String
    public var languageISO: String
    public var dialectISO: String
    public var transactionNumber: String
}
