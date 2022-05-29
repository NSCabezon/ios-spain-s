import Foundation

public struct ConfirmFundSubscriptionRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var language: String
    public var dialect: String
    public var typeSuscription: FundOperationsType
    public var amountForWS: String
    public var currency: String
    public var sharesNumber: String

    public var tokenPasos: String
    public var signatureDTO: SignatureDTO
    public var settlementValueDate: Date?
    public var directDebtBankCode: String
    public var directDebtBranchCode: String
    public var directDebtProduct: String
    public var directDebtContractNumber: String
    public var languageCode: String
    public var accountCurrencyCode: String
    public var settlementValueAmount: String
    public var settlementCurrencyAmount: String
}
