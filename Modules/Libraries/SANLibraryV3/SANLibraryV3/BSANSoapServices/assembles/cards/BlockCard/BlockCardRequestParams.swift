import Foundation

public struct BlockCardRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var version: String
    public var terminalId: String
    public var cardPAN: String
    public var cardContractProduct: String
    public var cardContractNumber: String
    public var cardContractBranchCode: String
    public var cardBankCode: String
    public var language: String
    public var blockText: String
    public var cardBlockType: CardBlockType
}
