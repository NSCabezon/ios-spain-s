import Foundation

public struct ValidateAccountTransferRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO?
    public var version: String
    public var terminalId: String
    public var language: String
    public var transferAmount: AmountDTO
    public var originBankCode: String
    public var originBranchCode: String
    public var originProduct: String
    public var originContractNumber: String
    public var destinationBankCode: String
    public var destinationBranchCode: String
    public var destinationProduct: String
    public var destinationContractNumber: String
    public var concept: String
}
