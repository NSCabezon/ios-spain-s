import Foundation

public struct GetCardTransactionDetailRequestParams {
    public var token: String
    public var version: String
    public var terminalId: String
    public var userDataDTO: UserDataDTO
    public var language: String
    public var cardContractBankCode: String
    public var cardContractBranchCode: String
    public var cardContractProduct: String
    public var cardContractNumber: String
    public var transactionOperationDate: String
    public var transactionBalanceCode: String
    public var transactionAnnotationDate: String
    public var transactionTransactionDay: String
    public var transactionCurrency: String
}
