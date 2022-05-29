import Foundation

public struct ConfirmBuyStockTypeOrderRequestParams {
    public var token: String
    public var stockTradingType: String
    public var userDataDTO: UserDataDTO?
    public var terminalId: String
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
    public var signatureDTO: SignatureDTO?
}
