import Foundation

public struct GetStockQuoteDetailRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var version: String
    public var terminalId: String
    public var language: String
    public var stockCode: String
    public var identificationNumber : String
}
