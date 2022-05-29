import Foundation

public struct GetAccountTransactionDetailRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    
    public var value: Decimal?
    public var currency: String
    public var transactionType: String
    public var transactionDay: String
    public var operationDate: Date?
    public var annotationDate: Date?
    public var dgoTerminalCode: String
    public var dgoNumber: String
    public var dgoCenter: String
    public var dgoCompany: String
    public var transactionNumber: String
    public var productSubtype: String
    public var terminalId: String
    public var version: String
    public var language: String
}
