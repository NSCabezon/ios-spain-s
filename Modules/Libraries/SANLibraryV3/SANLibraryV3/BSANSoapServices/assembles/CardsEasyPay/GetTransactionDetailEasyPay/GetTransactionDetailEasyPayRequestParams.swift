import Foundation
public struct GetTransactionDetailEasyPayRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var requestStatus: String
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var annotationDate: Date?
    public var amountTransactionValue: String
    public var currencyTransactionValue: String
    public var currency: String
    public var transactionDay: String
    public var balanceCode: String
    public var basicOperation: String
    public var bankOperation: String
}
