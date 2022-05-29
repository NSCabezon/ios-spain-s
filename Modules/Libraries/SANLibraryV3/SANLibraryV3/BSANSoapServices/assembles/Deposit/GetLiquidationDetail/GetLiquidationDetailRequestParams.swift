import Foundation

public struct GetLiquidationDetailRequestParams {
    public var token: String
    public var version: String
    public var terminalId: String
    public var userDataDTO: UserDataDTO
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var language: String
    public var validityClosingDate: Date?
    public var subcontractString: String
    public var settlementValue: Decimal?
    public var currencySettlement: String
}
