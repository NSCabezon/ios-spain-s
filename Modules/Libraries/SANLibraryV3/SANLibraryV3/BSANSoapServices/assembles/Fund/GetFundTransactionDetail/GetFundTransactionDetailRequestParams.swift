import Foundation

public struct GetFundTransactionDetailRequestParams {
    public var token: String
    public var version: String
    public var terminalId: String
    public var userDataDTO: UserDataDTO
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var language: String
    public var bankOperationCode: String
    public var applyDate: Date?
    public var valueDate: Date?
    public var transactionNumber: String
    public var productSubtypeCode: String
    public var value: Decimal?
    public var currencyValue: String
    public var settlementValue: Decimal?
    public var currencySettlement: String
}

