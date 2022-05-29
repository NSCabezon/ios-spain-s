import Foundation

public struct ValidateFundSubscriptionRequestParams {
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
}
