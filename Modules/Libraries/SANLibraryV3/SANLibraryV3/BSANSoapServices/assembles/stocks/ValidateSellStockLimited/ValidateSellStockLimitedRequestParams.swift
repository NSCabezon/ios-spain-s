import Foundation

public struct ValidateSellStockLimitedRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO?
    public var terminalId: String
    public var maxExchange: AmountDTO
    public var version: String
    public var language: String
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var stockCode: String
    public var identificationNumber: String
    public var tradesShares: String
    public var limitDate: Date?
}
