import Foundation

public struct DirectMoneyValidateRequestParams {
    public var token: String
    public var version: String
    public var terminalId: String
    public var userDataDTO: UserDataDTO
    public var cardContractProduct: String
    public var cardContractNumber: String
    public var cardContractBranchCode: String
    public var cardContractBankCode: String
    public var language: String
    public var directMoneyWholePart: String
    public var directMoneyDecimalPart: String
}
