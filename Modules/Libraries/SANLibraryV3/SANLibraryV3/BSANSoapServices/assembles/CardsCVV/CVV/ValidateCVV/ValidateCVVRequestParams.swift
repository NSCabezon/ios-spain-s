import Foundation

public struct ValidateCVVRequestParams {
    public var token: String
    public var cardDetailToken: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var PAN: String
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
}
