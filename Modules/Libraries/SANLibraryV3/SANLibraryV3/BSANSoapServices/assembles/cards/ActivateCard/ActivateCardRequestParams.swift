import Foundation

public struct ActivateCardRequestParams {
    public var token: String
    public var version: String
    public var terminalId: String
    public var userDataDTO: UserDataDTO
    public var cardPAN: String
    public var cardContractProduct: String
    public var cardContractNumber: String
    public var cardContractBranchCode: String
    public var cardBankCode: String
    public var cardExpirationDate: Date
    public var language: String
}
